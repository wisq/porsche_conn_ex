defmodule PorscheConnEx.Session do
  require Logger
  use GenServer

  alias PorscheConnEx.CookieJar

  @auth_server "identity.porsche.com"
  @client_id "UYsK00My6bCqJdbQhTQ0PbWmcSdIAMig"
  @redirect_uri "https://my.porsche.com/"

  defmodule Config do
    @derive {Inspect, except: [:password]}
    @enforce_keys [:username, :password]
    defstruct(
      language: "en",
      country: "US",
      username: nil,
      password: nil
    )

    def locale(%Config{language: lang, country: ctry}) do
      "#{String.downcase(lang)}_#{String.upcase(ctry)}"
    end
  end

  defmodule State do
    @enforce_keys [:config]
    defstruct(
      config: nil,
      auth_code: nil,
      token: nil
    )
  end

  defmodule Token do
    @enforce_keys [:type, :full, :api_key, :expires]
    defstruct(@enforce_keys)

    def from_body(
          %{
            "access_token" => access_token,
            "expires_in" => expires_in,
            "token_type" => type
          },
          now
        ) do
      %{"azp" => api_key} = decode_token(access_token)

      %Token{
        type: type,
        expires: now |> DateTime.add(expires_in),
        full: access_token,
        api_key: api_key
      }
    end

    def authorization(%Token{full: token, type: type}) do
      "#{type} #{token}"
    end

    defp decode_token(token) do
      [_, jwt, _] = String.split(token, ".")

      jwt
      |> :base64.decode(%{padding: false})
      |> Jason.decode!()
    end
  end

  def start_link(opts) do
    {config, opts} = Keyword.pop!(opts, :config)
    config = struct!(Config, config)
    GenServer.start_link(__MODULE__, config, opts)
  end

  def get(pid, url, params \\ %{}) do
    GenServer.call(pid, {:get, url, params})
  end

  @impl true
  def init(%Config{} = config) do
    state = %State{config: config}
    {:ok, _state} = authorize(state) |> IO.inspect(label: "authorize")
  end

  @impl true
  def handle_call({:get, url, params}, _from, state) do
    Req.new(
      url: url,
      headers: api_headers(state),
      params: params
    )
    |> CookieJar.with_cookies()
    |> Req.get()
  end

  defp api_headers(%State{token: token, config: config}) do
    %{
      "Authorization" => Token.authorization(token),
      "origin" => "https://my.porsche.com",
      "apikey" => token.api_key,
      "x-vrs-url-country" => config.country |> String.downcase(),
      "x-vrs-url-language" => config |> Config.locale()
    }
  end

  defp authorize(%State{config: config} = state) do
    with {:ok, auth_code} <- auth_login(config),
         {:ok, token} <- auth_token(auth_code) do
      {:ok, %State{state | auth_code: auth_code, token: token}}
    end
  end

  defp auth_login(%Config{} = config) do
    Logger.debug("Auth login")

    Req.new(
      url: "https://#{@auth_server}/authorize",
      redirect: false,
      params: %{
        response_type: "code",
        client_id: @client_id,
        redirect_uri: @redirect_uri,
        ui_locales: "#{config.language}-#{config.country}",
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
    |> CookieJar.with_cookies()
    |> Req.get()
    |> then(fn
      {:ok, %{status: 302} = resp} ->
        [location] = Req.Response.get_header(resp, "location")

        case URI.parse(location).query |> URI.decode_query() do
          %{"code" => auth_code} ->
            {:ok, auth_code}

          %{"state" => auth_state} ->
            auth_continue(config, auth_state)
        end
    end)
  end

  defp auth_continue(%Config{} = config, auth_state) do
    with :ok <- auth_post_username(auth_state, config),
         {:ok, resume_url} <- auth_post_password(auth_state, config),
         {:ok, auth_code} <- auth_login_final(resume_url) do
      {:ok, auth_code}
    end
  end

  defp auth_post_username(auth_state, %Config{} = config) do
    Logger.debug("Auth posting username")

    Req.new(
      url: "https://#{@auth_server}/u/login/identifier",
      redirect: false,
      params: %{"state" => auth_state},
      form: %{
        "state" => auth_state,
        "username" => config.username,
        "js-available" => true,
        "webauthn-available" => false,
        "is-brave" => false,
        "webauthn-platform-available" => false,
        "action" => "default"
      }
    )
    |> CookieJar.with_cookies()
    |> Req.post()
    |> then(fn
      {:ok, %{status: 400}} ->
        {:error, :captcha_required}

      {:ok, %{status: 302}} ->
        :ok
    end)
  end

  defp auth_post_password(auth_state, %Config{} = config) do
    Logger.debug("Auth posting password")

    Req.new(
      url: "https://#{@auth_server}/u/login/password",
      redirect: false,
      params: %{"state" => auth_state},
      form: %{
        "state" => auth_state,
        "username" => config.username,
        "password" => config.password,
        "action" => "default"
      }
    )
    |> CookieJar.with_cookies()
    |> Req.post()
    |> then(fn
      {:ok, %{status: 302} = resp} ->
        [location] = Req.Response.get_header(resp, "location")
        {:ok, location}
    end)
  end

  defp auth_login_final(url) do
    Logger.debug("Auth finalizing")

    Req.new(url: url, base_url: "https://#{@auth_server}", redirect: false)
    |> CookieJar.with_cookies()
    |> Req.get()
    |> then(fn
      {:ok, %{status: 302} = resp} ->
        [location] = Req.Response.get_header(resp, "location")
        auth = URI.parse(location).query |> URI.decode_query()
        {:ok, Map.fetch!(auth, "code")}
    end)
  end

  defp auth_token(auth_code) do
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
    |> CookieJar.with_cookies()
    |> Req.post()
    |> then(fn
      {:ok, %{status: 200, body: body}} ->
        {:ok, Token.from_body(body, now)}
    end)
  end
end
