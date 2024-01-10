defmodule PorscheConnEx.Session do
  require Logger
  use GenServer

  alias PorscheConnEx.Cookies
  alias PorscheConnEx.Config

  @auth_server "identity.porsche.com"
  @client_id "UYsK00My6bCqJdbQhTQ0PbWmcSdIAMig"
  @redirect_uri "https://my.porsche.com/"

  # Refresh tokens ten minutes before they're set to expire.
  @refresh_margin {10, :minute}
  # Retry the refresh each minute on failure.
  @retry_delay {1, :minute}

  defmodule Credentials do
    @derive {Inspect, except: [:password]}
    @enforce_keys [:username, :password]
    defstruct(
      username: nil,
      password: nil
    )

    def new(opts) do
      struct!(__MODULE__, opts)
    end
  end

  defmodule State do
    @enforce_keys [:config, :credentials, :cookie_jar]
    defstruct(
      config: nil,
      credentials: nil,
      cookie_jar: nil,
      auth_code: nil,
      token: nil,
      refresh_at: nil
    )
  end

  defmodule Token do
    @enforce_keys [:authorization, :api_key, :expires_at]
    defstruct(@enforce_keys)

    def from_body(
          %{
            "access_token" => access_token,
            "expires_in" => expires_in,
            "token_type" => token_type
          },
          now
        ) do
      %{"azp" => api_key} = decode_token(access_token)

      %Token{
        api_key: api_key,
        authorization: "#{token_type} #{access_token}",
        expires_at: now |> DateTime.add(expires_in)
      }
    end

    defp decode_token(token) do
      [_, jwt, _] = String.split(token, ".")

      jwt
      |> :base64.decode(%{padding: false})
      |> Jason.decode!()
    end
  end

  def start_link(opts) do
    {config, opts} = Keyword.pop(opts, :config, [])
    {creds, opts} = Keyword.pop!(opts, :credentials)
    GenServer.start_link(__MODULE__, {Config.new(config), Credentials.new(creds)}, opts)
  end

  def headers(pid) do
    GenServer.call(pid, :headers)
  end

  @impl true
  def init({%Config{} = config, %Credentials{} = creds}) do
    {:ok, jar} = CookieJar.start_link()
    state = %State{config: config, credentials: creds, cookie_jar: jar}

    {:ok, state} = authorize(state)
    {:ok, state, {:continue, :refresh}}
  end

  @impl true
  def handle_call(:headers, _from, state) do
    {
      :reply,
      %{
        "Authorization" => state.token.authorization,
        "origin" => "https://my.porsche.com",
        "apikey" => state.token.api_key,
        "x-vrs-url-country" => Config.url_country(state.config),
        "x-vrs-url-language" => Config.url_language(state.config)
      },
      state,
      {:continue, :refresh}
    }
  end

  @impl true
  def handle_continue(:refresh, state) do
    now = DateTime.utc_now()

    if DateTime.compare(state.token.expires_at, now) == :lt do
      Logger.critical("Token has expired, unable to refresh in time.")
      {:stop, :expired_token, state}
    else
      timeout = DateTime.diff(state.refresh_at, now, :millisecond) |> max(1)
      {:noreply, state, timeout}
    end
  end

  @impl true
  def handle_info(:timeout, state) do
    case authorize(state) do
      {:ok, state} ->
        {:noreply, state, {:continue, :refresh}}

      _ ->
        Logger.error("Auth refresh failed, will retry.")
        {retry_amount, retry_units} = @retry_delay
        refresh_at = state.refresh_at |> DateTime.add(retry_amount, retry_units)
        {:ok, %State{state | refresh_at: refresh_at}, {:continue, :refresh}}
    end
  end

  defp authorize(%State{credentials: creds, config: config} = state) do
    with {:ok, auth_code} <- auth_login(config, creds, state.cookie_jar),
         {:ok, token} <- auth_token(auth_code, state.cookie_jar) do
      {refresh_amount, refresh_units} = @refresh_margin

      {:ok,
       %State{
         state
         | auth_code: auth_code,
           token: token,
           refresh_at: token.expires_at |> DateTime.add(-refresh_amount, refresh_units)
       }}
    end
  end

  defp auth_login(%Config{} = config, %Credentials{} = creds, cookie_jar) do
    Logger.debug("Auth login")

    Req.new(
      url: "https://#{@auth_server}/authorize",
      redirect: false,
      params: %{
        response_type: "code",
        client_id: @client_id,
        redirect_uri: @redirect_uri,
        ui_locales: Config.ui_locales(config),
        audience: "https://api.porsche.com",
        scope:
          ~w"""
            openid profile email
            pid:user_profile.addresses:read
            pid:user_profile.birthdate:read
            pid:user_profile.dealers:read
            pid:user_profile.emails:read
            pid:user_profile.locale:read
            pid:user_profile.name:read
            pid:user_profile.phones:read
            pid:user_profile.porscheid:read
            pid:user_profile.vehicles:read
            pid:user_profile.vehicles:register
          """
          |> Enum.join(" ")
      }
    )
    |> Cookies.using_jar(cookie_jar)
    |> Req.get()
    |> then(fn
      {:ok, %{status: 302} = resp} ->
        [location] = Req.Response.get_header(resp, "location")

        case URI.parse(location).query |> URI.decode_query() do
          %{"code" => auth_code} ->
            {:ok, auth_code}

          %{"state" => auth_state} ->
            auth_continue(creds, auth_state, cookie_jar)
        end
    end)
  end

  defp auth_continue(%Credentials{} = creds, auth_state, cookie_jar) do
    with :ok <- auth_post_username(auth_state, creds, cookie_jar),
         {:ok, resume_url} <- auth_post_password(auth_state, creds, cookie_jar),
         {:ok, auth_code} <- auth_login_final(resume_url, cookie_jar) do
      {:ok, auth_code}
    end
  end

  defp auth_post_username(auth_state, %Credentials{} = creds, cookie_jar) do
    Logger.debug("Auth posting username")

    Req.new(
      url: "https://#{@auth_server}/u/login/identifier",
      redirect: false,
      params: %{"state" => auth_state},
      form: %{
        "state" => auth_state,
        "username" => creds.username,
        "js-available" => true,
        "webauthn-available" => false,
        "is-brave" => false,
        "webauthn-platform-available" => false,
        "action" => "default"
      }
    )
    |> Cookies.using_jar(cookie_jar)
    |> Req.post()
    |> then(fn
      {:ok, %{status: 400}} ->
        {:error, :captcha_required}

      {:ok, %{status: 302}} ->
        :ok
    end)
  end

  defp auth_post_password(auth_state, %Credentials{} = creds, cookie_jar) do
    Logger.debug("Auth posting password")

    Req.new(
      url: "https://#{@auth_server}/u/login/password",
      redirect: false,
      params: %{"state" => auth_state},
      form: %{
        "state" => auth_state,
        "username" => creds.username,
        "password" => creds.password,
        "action" => "default"
      }
    )
    |> Cookies.using_jar(cookie_jar)
    |> Req.post()
    |> then(fn
      {:ok, %{status: 302} = resp} ->
        [location] = Req.Response.get_header(resp, "location")
        {:ok, location}
    end)
  end

  defp auth_login_final(url, cookie_jar) do
    Logger.debug("Auth finalizing")

    Req.new(url: url, base_url: "https://#{@auth_server}", redirect: false)
    |> Cookies.using_jar(cookie_jar)
    |> Req.get()
    |> then(fn
      {:ok, %{status: 302} = resp} ->
        [location] = Req.Response.get_header(resp, "location")
        auth = URI.parse(location).query |> URI.decode_query()
        {:ok, Map.fetch!(auth, "code")}
    end)
  end

  defp auth_token(auth_code, cookie_jar) do
    Logger.debug("Auth token")
    now = DateTime.utc_now()

    Req.new(
      url: "https://#{@auth_server}/oauth/token",
      redirect: false,
      form: %{
        "client_id" => @client_id,
        "grant_type" => "authorization_code",
        "code" => auth_code,
        "redirect_uri" => @redirect_uri
      }
    )
    |> Cookies.using_jar(cookie_jar)
    |> Req.post()
    |> then(fn
      {:ok, %{status: 200, body: body}} ->
        {:ok, Token.from_body(body, now)}
    end)
  end
end
