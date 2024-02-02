defmodule PorscheConnEx.Session do
  @moduledoc """
  Handles configuration and authentication of an API session.

  Starting a session will acquire an access token from the Porsche Connect API
  at startup, and then acquire a new token whenever the current token is
  nearing expiry.  It also serves as stateful storage of the
  `PorscheConnEx.Config` structure used to configure the session.

  All `PorscheConnEx.Client` calls require both HTTP authentication headers and
  the `PorscheConnEx.Config` structure, which are bundled together into a
  `PorscheConnEx.Session.RequestData` structure.
  """
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
    @moduledoc false
    @derive {Inspect, except: [:password]}
    @enforce_keys [:username, :password]
    defstruct(
      username: nil,
      password: nil
    )

    @type t :: %__MODULE__{
            username: binary,
            password: binary
          }

    @type key :: :username | :password
    @spec new(Keyword.t() | %{key => any}) :: t()

    def new(opts) do
      struct!(__MODULE__, opts)
    end
  end

  defmodule State do
    @moduledoc false
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
    @moduledoc false
    @enforce_keys [:authorization, :api_key, :expires_at]
    defstruct(@enforce_keys)

    @type t :: %__MODULE__{
            authorization: binary,
            api_key: binary,
            expires_at: DateTime.t()
          }

    @spec from_body(%{binary => term}, DateTime.t()) :: t()

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

  defmodule RequestData do
    @moduledoc """
    Structure containing the necessary data to perform API calls.

    Created and returned by `PorscheConnEx.Session.request_data/1`.

    ## Fields

    - `config` — a `PorscheConnEx.Config` structure containing API configuration
    - `headers` — a `Map` of HTTP authentication headers

    By altering this structure, you can, in theory, authenticate with the API
    using one configuration, then make calls with a different configuration.
    I'm not sure why you'd do this, though, and I wouldn't recommend it — some
    aspects of the API are defined at authentication rather than per-request.
    """
    @enforce_keys [:config, :headers]
    defstruct(@enforce_keys)

    @type t :: %__MODULE__{
            config: Config.t(),
            headers: %{binary => binary}
          }
  end

  @type t :: GenServer.server() | RequestData.t()

  @doc """
  Starts a session and authenticates with the API.

  ## Options

    * `credentials` (required) - a keyword list or map containing
      * `username` (required) - your Porsche Connect username
      * `password` (required) - your Porsche Connect password
    * `config` (optional) - a keyword list, a map, or a `PorscheConnEx.Config` structure
      * see that module for fields and other details

  This function also accepts all the options accepted by `GenServer.start_link/3`.

  ## Return values

  Same as `GenServer.start_link/3`.  Note that this function will block until
  the initial API authentication is complete.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    {config, opts} = Keyword.pop(opts, :config, [])
    {creds, opts} = Keyword.pop!(opts, :credentials)
    GenServer.start_link(__MODULE__, {Config.new(config), Credentials.new(creds)}, opts)
  end

  @doc """
  Returns a session's configuration and authentication details.

  ## Arguments

  - `pid_or_rdata` can be either
    - the PID of a running `Session` process,
    - the registered name of a running `Session` process, or
    - an existing `PorscheConnEx.Session.RequestData` structure.

  ## Return value

  Returns a `PorscheConnEx.Session.RequestData` structure containing the
  starting configuration and current authentication details associated with the
  session.

  If given an existing `RequestData` structure, then that structure will be
  returned verbatim.  This means that `PorscheConnEx.Client` calls can all
  effectively also receive a `RequestData` structure as their first argument,
  in lieu of a running session.  (This is used in e.g.
  `PorscheConnEx.Client.wait/2` to avoid unnecessary requests.)

  Beware that authentication tokens do expire, and you should not use a given
  `RequestData` structure for more than a few minutes before fetching another.
  """
  @spec request_data(GenServer.server() | RequestData.t()) :: RequestData.t()
  def request_data(pid_or_rdata)

  def request_data(%RequestData{} = rdata), do: rdata

  def request_data(pid) when is_pid(pid) or is_atom(pid) do
    GenServer.call(pid, :request_data)
  end

  @impl true
  def init({%Config{} = config, %Credentials{} = creds}) do
    {:ok, jar} = CookieJar.start_link()
    state = %State{config: config, credentials: creds, cookie_jar: jar}

    {:ok, state} = authorize(state)
    {:ok, state, {:continue, :refresh}}
  end

  @impl true
  def handle_call(:request_data, _from, state) do
    {
      :reply,
      %RequestData{
        config: state.config,
        headers: %{
          "Authorization" => state.token.authorization,
          "origin" => "https://my.porsche.com",
          "apikey" => state.token.api_key,
          "x-vrs-url-country" => Config.url_country(state.config),
          "x-vrs-url-language" => Config.url_language(state.config)
        }
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
