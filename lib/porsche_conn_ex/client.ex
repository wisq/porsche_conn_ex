defmodule PorscheConnEx.Client do
  @moduledoc """
  Issues requests to the Porsche Connect API.

  ## Common arguments

  All functions in this module require one of the following as their first argument:

  - a `PorscheConnEx.Session` process (by PID or by name)
  - a `PorscheConnEx.Session.RequestData` structure

  This will both configure and authenticate the API call, based
  on the starting arguments for the `PorscheConnEx.Session` process.

  Most calls require the [17-character
  VIN](https://en.wikipedia.org/wiki/Vehicle_identification_number) of the
  vehicle to be queried or altered.  This can be retrieved using
  `PorscheConnEx.Client.vehicles/1`.

  Several calls related to electric vehicles also require the vehicle model.
  This can be retrieved using `PorscheConnEx.Client.capabilities/2`.

  ## Blocking & timeouts

  The actual HTTP request will be performed in the calling process and will
  block until complete.  While there is no explicit per-call timeout, the
  effective timeout can be influenced by setting `http_options` — see
  `PorscheConnEx.Config` for details.

  ## Error values

  The Porsche Connect API tends to be fairly opaque with errors, generating the
  same "unknown error" result for most errors.  As a result, the most common
  error value from this module will be `{:error, :unknown}`.  Hopefully, the
  cause of the error will be reasonably obvious based on context.

  Lower-level errors will tend to be more descriptive.  These may include, but
  are not limited to, the following:

  - `{:error, :nxdomain}` - cannot find the API DNS name (are you offline?)
  - `{:error, :not_found}` - any "404 Not Found" HTTP error
    - usually caused by choosing an unknown locale in your configuration
  - `{:error, :timeout}` - the HTTP request timed out
  """
  require Logger

  alias PorscheConnEx.Session
  alias PorscheConnEx.Config
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Struct.Emobility.{Timer, ChargingProfile}

  defmodule PendingRequest do
    @moduledoc """
    Return value from API calls that may take a long time to complete.

    Some `PorscheConnEx.Client` calls will return `{:ok, %PendingRequest{...}}`
    to indicate that their request has been accepted but not necessarily
    completed yet.  To determine the eventual fate of the request, see below.

    ## For write requests

    Once a write request has been submitted, no further action is required on
    the part of the library user — if possible, the requested action will be
    send and performed on the vehicle. However, if the vehicle cannot be
    reached within a certain amount of time, the call will ultimately fail, and
    nothing will happen.

    To discover the fate of your request, you can use one of two approaches:

    - call `PorscheConnEx.Client.poll/2` repeatedly to check the status of the
      request, waiting for a status other than `:in_progress`
    - call `PorscheConnEx.Client.wait/3` to do the above for you, polling
      repeatedly until it receives a status other than `:in_progress`

    Note that, in some cases, you may not care about what happens to the
    request.  For example, if your code is periodically checking
    `PorscheConnEx.Client.emobility/3` and updating timers and/or charging profiles
    based on that data, then it may be fine to just "fire and forget" requests,
    since any failures will presumably be noticed and retried on the next check.

    ## For read requests

    There is currently only one read request that uses pending requests —
    `PorscheConnEx.Client.current_overview/2`.  Obviously, it would not make
    sense to just leave this request pending, since the whole point is to
    retrieve the most recent vehicle overview data.

    Read requests differ from write requests in that, once the request has
    succeeded, there is an extra call required to retrieve the final output
    data.  As such, there are two possible approaches:

    - call `PorscheConnEx.Client.poll/2` repeatedly to check the status of the
      request until you get a status other than `:in_progress`, then run
      `PorscheConnEx.Client.complete/2` to retrieve the final results (but only
      if the status is `:success`)
    - call `PorscheConnEx.Client.wait/3` to do all of the above for you — i.e.
      polling repeatedly until it receives a status other than `:in_progress`,
      then retrieving the final results for you (if status is `:success`)

    Note that `PorscheConnEx.Client.complete/2` will **not** prevent you from
    trying to retrieve the final results of a failed or still-in-progress
    request, but the results will almost certainly fail to parse due to missing
    data.  Wait for a poll result of `:success` first.
    """

    @enforce_keys [:id, :poll_url]
    defstruct(
      id: nil,
      poll_url: nil,
      final_url: nil,
      final_handler: nil
    )
  end

  @doc """
  Returns a list of vehicles assigned to the current account.

  ## Arguments

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.

  ## Return values

  On success, returns `{:ok, list}`, where `list` is a list of
  `PorscheConnEx.Struct.Vehicle` structures.

  On error, returns `{:error, _}`.
  """
  def vehicles(session) do
    rdata = Session.request_data(session)

    get(rdata, "/core/api/v3/#{Config.url(rdata.config)}/vehicles")
    |> load_as_list_of(Struct.Vehicle)
  end

  @doc """
  Returns general status information about a particular vehicle.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, status}`, where `status` is a
  `PorscheConnEx.Struct.Status` structure.

  On error, returns `{:error, _}`.
  """
  def status(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/vehicle-data/#{Config.url(rdata.config)}/status/#{vin}")
    |> load_as(Struct.Status)
  end

  @doc """
  Returns extremely basic information about a particular vehicle.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, summary}`, where `summary` is a
  `PorscheConnEx.Struct.Summary` structure.

  On error, returns `{:error, _}`.
  """
  def summary(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/service-vehicle/vehicle-summary/#{vin}")
    |> load_as(Struct.Summary)
  end

  @doc """
  Returns recent overview information about a particular vehicle.

  The vehicle is not queried directly; instead, this call retrieves data stored
  server-side about the vehicle, based on the vehicle's most recent update.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, overview}`, where `overview` is a
  `PorscheConnEx.Struct.Overview` structure.

  On error, returns `{:error, _}`.
  """
  def stored_overview(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/service-vehicle/#{Config.url(rdata.config)}/vehicle-data/#{vin}/stored")
    |> load_as(Struct.Overview)
  end

  @doc """
  Fetches current overview information about a particular vehicle.

  The vehicle will be queried directly, and the information received should be
  fully up-to-date.  This may take a while, or fail, especially if the vehicle
  is turned off or has limited cellular signal.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, pending}`, where `pending` is a
  `PorscheConnEx.Client.PendingRequest` structure.

  To wait for and retrieve the results, use `PorscheConnEx.Client.wait/3`.
  Alternatively, you may call `PorscheConnEx.Client.poll/2` and
  `PorscheConnEx.Client.complete/2` directly.

  On error, returns `{:error, _}`.
  """
  def current_overview(session, vin) do
    rdata = Session.request_data(session)
    url = "/service-vehicle/#{Config.url(rdata.config)}/vehicle-data/#{vin}/current/request"

    post(
      rdata,
      url,
      # avoids "missing content-length" error
      body: ""
    )
    |> as_pending(
      poll_url: fn req_id -> "#{url}/#{req_id}/status" end,
      final_url: fn req_id -> "#{url}/#{req_id}" end,
      final_handler: &load_as(&1, Struct.Overview)
    )
  end

  @doc """
  Returns information about the capabilities of a particular vehicle.

  This includes the model identifier, which is used in several other calls
  relating to electric vehicle batteries and charging.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, capabs}`, where `capabs` is a
  `PorscheConnEx.Struct.Capabilities` structure.

  On error, returns `{:error, _}`.
  """
  def capabilities(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/service-vehicle/vcs/capabilities/#{vin}")
    |> load_as(Struct.Capabilities)
  end

  @doc """
  Returns a list of maintenance events regarding a particular vehicle.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, list}`, where `list` is a list of
  `PorscheConnEx.Struct.Maintenance` structures.

  On error, returns `{:error, _}`.
  """
  def maintenance(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/predictive-maintenance/information/#{vin}")
    |> load_as(Struct.Maintenance)
  end

  @doc """
  Returns comprehensive data about the electric charging capabilities and
  behaviour of a particular vehicle.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.
  - `model` is the model identifier of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, emob}`, where `emob` is a
  `PorscheConnEx.Struct.Emobility` structure.

  On error, returns `{:error, _}`.
  """
  def emobility(session, vin, model) do
    rdata = Session.request_data(session)

    get(
      rdata,
      "/e-mobility/#{Config.url(rdata.config)}/#{model}/#{vin}",
      params: %{timezone: rdata.config.timezone}
    )
    |> load_as(Struct.Emobility)
  end

  @doc """
  Returns the current global position of a particular vehicle.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, position}`, where `position` is a
  `PorscheConnEx.Struct.Position` structure.

  On error, returns `{:error, _}`.
  """
  def position(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/service-vehicle/car-finder/#{vin}/position")
    |> load_as(Struct.Position)
  end

  @doc """
  Returns a list of short-term trips taken by a particular vehicle.

  These trips are automatically generated, presumably based on when the vehicle
  is turned on/off, parked, etc.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, list}`, where `list` is a list of
  `PorscheConnEx.Struct.Trip` structures.

  On error, returns `{:error, _}`.
  """
  def trips_short_term(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/service-vehicle/#{Config.url(rdata.config)}/trips/#{vin}/SHORT_TERM")
    |> load_as_list_of(Struct.Trip)
  end

  @doc """
  Returns a list of long-term trips taken by a particular vehicle.

  These trips are generated when the user clears the short-term trip list.  The
  most recent one should be a summary of all the short-term trips.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be queried.

  ## Return values

  On success, returns `{:ok, list}`, where `list` is a list of
  `PorscheConnEx.Struct.Trip` structures.

  On error, returns `{:error, _}`.
  """
  def trips_long_term(session, vin) do
    rdata = Session.request_data(session)

    get(rdata, "/service-vehicle/#{Config.url(rdata.config)}/trips/#{vin}/LONG_TERM")
    |> load_as_list_of(Struct.Trip)
  end

  @doc """
  Creates or updates a timer for an electric vehicle.

  Timers are used to schedule charging, and/or to climatise (preheat/cool) the
  vehicle, e.g. in preparation for an upcoming trip.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be updated.
  - `model` is the model identifier of the vehicle to be updated.
  - `timer` is a `PorscheConnEx.Struct.Emobility.Timer` structure.

  ## Timer slots

  There are five slots available for timers, identified by the `timer.id` field.
  If `timer` has a non-nil `id` value, then it will overwrite that slot.

  If `timer` has a nil `id` value, then it will be placed in the first
  empty slot.  If no slots are available, this function will return an error.

  ## Return values

  On success, returns `{:ok, pending}`, where `pending` is a
  `PorscheConnEx.Client.PendingRequest` structure.  See that structure's
  documentation for details.

  On error, returns `{:error, _}`.
  """
  def put_timer(session, vin, model, timer) do
    rdata = Session.request_data(session)
    base = "/e-mobility/#{Config.url(rdata.config)}/#{model}/#{vin}"

    with {:ok, timer_json} <- Timer.dump(timer) do
      case timer.id do
        nil -> post(rdata, "#{base}/timer", json: timer_json)
        n when is_integer(n) -> put(rdata, "#{base}/timer", json: timer_json)
      end
      |> as_pending(poll_url: fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end)
    end
  end

  @doc """
  Deletes a timer for an electric vehicle.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be updated.
  - `model` is the model identifier of the vehicle to be updated.
  - `timer_id` is an integer indicating the slot to be deleted.

  For details about the `timer_id` value, see `PorscheConnEx.Client.put_timer/4`.

  ## Return values

  On success, returns `{:ok, pending}`, where `pending` is a
  `PorscheConnEx.Client.PendingRequest` structure.  See that structure's
  documentation for details.

  On error, returns `{:error, _}`.
  """
  def delete_timer(session, vin, model, timer_id) do
    rdata = Session.request_data(session)
    base = "/e-mobility/#{Config.url(rdata.config)}/#{model}/#{vin}"

    delete(rdata, "#{base}/timer/#{timer_id}")
    |> as_pending(poll_url: fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end)
  end

  @doc """
  Creates or updates a charging profile for an electric vehicle.

  Charging profiles define basic charging parameters, such as charging targets,
  preferred charging hours, etc.  They can also be tied to a specific
  geographical location, such as a home or office.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be updated.
  - `model` is the model identifier of the vehicle to be updated.
  - `profile` is a `PorscheConnEx.Struct.Emobility.ChargingProfile` structure.

  ## Profile slots

  There are a limited number of slots available for charging profiles,
  identified by the `profile.id` field.  From testing to date, it appears that
  profile #4 is the "General" (default) profile, and profiles 5 through 7 are
  "local" (user-defined) profiles.

  If `profile` has a non-nil `id` value, then it will overwrite that slot.

  If `profile` has a nil `id` value, then it will be placed in the first empty
  "local" slot.  If no such slots are available, this function will return an
  error.

  ## Return values

  On success, returns `{:ok, pending}`, where `pending` is a
  `PorscheConnEx.Client.PendingRequest` structure.  See that structure's
  documentation for details.

  On error, returns `{:error, _}`.
  """
  def put_charging_profile(session, vin, model, profile) do
    rdata = Session.request_data(session)
    base = "/e-mobility/#{Config.url(rdata.config)}/#{model}/#{vin}"

    with {:ok, profile_json} <- ChargingProfile.dump(profile) do
      case profile.id do
        nil -> post(rdata, "#{base}/profile", json: profile_json)
        n when is_integer(n) -> put(rdata, "#{base}/profile", json: profile_json)
      end
      |> as_pending(poll_url: fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end)
    end
  end

  @doc """
  Deletes a charging profile for an electric vehicle.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be updated.
  - `model` is the model identifier of the vehicle to be updated.
  - `profile_id` is an integer indicating the slot to be deleted.

  For details about the `profile_id` value, see
  `PorscheConnEx.Client.put_charging_profile/4`.

  Note that you probably shouldn't try to delete the "General" profile (#4), or
  any other non-user-defined profiles.  (I would assume you'd get an error if
  you tried, but I'm not brave enough to find out.)

  ## Return values

  On success, returns `{:ok, pending}`, where `pending` is a
  `PorscheConnEx.Client.PendingRequest` structure.  See that structure's
  documentation for details.

  On error, returns `{:error, _}`.
  """
  def delete_charging_profile(session, vin, model, profile_id) do
    rdata = Session.request_data(session)
    base = "/e-mobility/#{Config.url(rdata.config)}/#{model}/#{vin}"

    delete(rdata, "#{base}/profile/#{profile_id}")
    |> as_pending(poll_url: fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end)
  end

  @doc """
  Starts or cancels the "direct climatisation" (preheat/cool) feature.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `vin` is the VIN of the vehicle to be updated.
  - `climate` is a boolean indicating whether to turn on climatisation (`true`) or turn it off (`false`).

  ## Climatisation timer

  When climatisation is off, turning it on will enable it for the next 60
  minutes, after which time it will automatically turn off again.

  If climatisation is already in the indicated state, no action will occur, and
  this timer will not be reset.

  ## Return values

  On success, returns `{:ok, pending}`, where `pending` is a
  `PorscheConnEx.Client.PendingRequest` structure.  See that structure's
  documentation for details.

  On error, returns `{:error, _}`.
  """
  def climate_set(session, vin, climate) when is_boolean(climate) do
    rdata = Session.request_data(session)
    base = "/e-mobility/#{Config.url(rdata.config)}/#{vin}/toggle-direct-climatisation"

    post(rdata, "#{base}/#{climate}", json: %{})
    |> as_pending(poll_url: fn req_id -> "#{base}/status/#{req_id}" end)
  end

  defp get(rdata, url, opts \\ []) do
    req_new(rdata, url, opts)
    |> Req.get()
  end

  defp post(rdata, url, opts) do
    req_new(rdata, url, opts)
    |> Req.post()
  end

  defp put(rdata, url, opts) do
    req_new(rdata, url, opts)
    |> Req.put()
  end

  defp delete(rdata, url, opts \\ []) do
    req_new(rdata, url, opts)
    |> Req.delete()
  end

  defp req_new(rdata, url, opts) do
    config = rdata.config
    headers = rdata.headers

    config.http_options
    |> Keyword.merge(
      url: url,
      base_url: config.api_url
    )
    |> Keyword.merge(opts)
    |> Keyword.update(:headers, headers, &Map.merge(&1, headers))
    |> Req.new()
    |> maybe_add_debug()
  end

  # successful(?)
  defp handle_response({:ok, %{status: status, body: body}}, fun)
       when status >= 200 and status < 300,
       do: fun.(status, body)

  # 404 error (usually bad locale)
  defp handle_response({:ok, %{status: 404}}, _), do: {:error, :not_found}
  # other HTTP errors
  defp handle_response({:ok, %{status: _}}, _), do: {:error, :unknown}
  # transport error (nxdomain, timeout, etc)
  defp handle_response({:error, %Mint.TransportError{reason: reason}}, _), do: {:error, reason}
  # unknown error
  defp handle_response({:error, _} = err, _), do: err

  defp load_as(result, module) do
    handle_response(result, fn
      200, map when is_map(map) -> module.load(map)
      200, _ -> {:error, :unexpected_data}
      _, _ -> {:error, :unknown}
    end)
  end

  defp load_as_list_of(result, module) do
    handle_response(result, fn
      200, list when is_list(list) ->
        list
        |> Enum.flat_map_reduce(:ok, fn item, _ ->
          case module.load(item) do
            {:ok, struct} -> {[struct], :ok}
            {:error, _} = err -> {:halt, err}
          end
        end)
        |> then(fn
          {list, :ok} -> {:ok, list}
          {_, {:error, _} = err} -> err
        end)

      200, _ ->
        {:error, :unexpected_data}

      _, _ ->
        {:error, :unknown}
    end)
  end

  defp as_pending(result, opts) do
    with {:ok, request_id} <- get_request_id(result) do
      opts
      |> Enum.map(fn
        {key, fun} when key in [:poll_url, :final_url] and is_function(fun) ->
          {key, fun.(request_id)}

        other ->
          other
      end)
      |> Keyword.put(:id, request_id)
      |> then(fn opts ->
        {:ok, struct!(PendingRequest, opts)}
      end)
    end
  end

  defp get_request_id(result) do
    handle_response(result, fn
      status, body when status in [200, 202] ->
        case body do
          %{"requestId" => req_id} -> {:ok, req_id}
          %{"actionId" => req_id} -> {:ok, req_id}
          _ -> {:error, :unexpected_data}
        end

      _, _ ->
        {:error, :unknown}
    end)
  end

  @doc """
  Checks the status of a pending request.

  See `PorscheConnEx.Client.PendingRequest` for usage details.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `pending` is a `PorscheConnEx.Client.PendingRequest` structure.

  ## Return values

  - Returns `{:ok, :in_progress}` if the request is still ongoing.
  - Returns `{:ok, :success}` if the request completed successfully.
  - Returns `{:error, :failed}` if the request failed.
  - Returns `{:error, _}` on other errors.
  """
  def poll(session, %PendingRequest{} = pending) do
    rdata = Session.request_data(session)

    get(rdata, pending.poll_url)
    |> handle_response(fn
      status, body when status in [200, 202] ->
        case body do
          %{"status" => status} -> {:ok, status}
          %{"actionState" => status} -> {:ok, status}
          _ -> {:error, :unexpected_data}
        end

      502, %{"pcckErrorKey" => "EC.TIMERS_AND_PROFILES.ERROR_EXECUTION_FAILED"} ->
        {:error, :failed}

      _, _ ->
        {:error, :unknown}
    end)
    |> then(fn
      {:ok, "IN_PROGRESS"} -> {:ok, :in_progress}
      {:ok, "SUCCESS"} -> {:ok, :success}
      {:ok, "FAIL"} -> {:error, :failed}
      {:error, _} = err -> err
    end)
  end

  @doc """
  Retrieves the final result of a pending request.

  See `PorscheConnEx.Client.PendingRequest` for usage details.  Note that this
  function only applies to requests that read data, and will not match
  write-only requests.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `pending` is a `PorscheConnEx.Client.PendingRequest` structure.

  ## Return values

  On success, returns `{:ok, result}`, where the nature of `result` depends on
  the type of request being completed.

  On error, returns `{:error, _}`.
  """
  def complete(session, %PendingRequest{final_url: final_url, final_handler: final_handler})
      when not is_nil(final_url) and not is_nil(final_handler) do
    rdata = Session.request_data(session)

    get(rdata, final_url)
    |> final_handler.()
  end

  @default_wait_count 120
  @default_wait_delay 1000

  @doc """
  Polls a pending request until it finishes, then completes it if applicable.

  See `PorscheConnEx.Client.PendingRequest` for usage details.

  ## Arguments

  - `session` is a `PorscheConnEx.Session` pid/name or a
    `PorscheConnEx.Session.RequestData` structure.
  - `pending` is a `PorscheConnEx.Client.PendingRequest` structure.
  - `opts` is a keyword-list of options and their values:
    - `count` (default: #{@default_wait_count}) is the maximum number of times to poll before giving up.
    - `delay` (default: #{@default_wait_delay}) is the delay (in milliseconds) to wait between poll attempts.

  ## Return values

  If the request ultimately finishes successfully, returns `{:ok, result}`,
  where the nature of `result` depends on the type of request being completed.
  (For write-only operations, `result` will just be `:success`, as per the return
  value of `poll/2`.)

  If the request fails, returns `{:error, :failed}` as per the return value of `poll/2`.

  If the result is still pending after `count` polls, returns `{:error,
  :in_progress}`.  You may call `poll/2` or `wait/2` again if you still want to
  continue waiting.

  On other errors, returns `{:error, _}`.
  """
  def wait(session, %PendingRequest{} = pending, opts \\ []) do
    rdata = Session.request_data(session)
    wait_count = Keyword.get(opts, :count, @default_wait_count)
    wait_delay = Keyword.get(opts, :delay, @default_wait_delay)

    1..wait_count//1
    |> Enum.reduce_while({:ok, :in_progress}, fn _, _ ->
      Process.sleep(wait_delay)

      case poll(rdata, pending) do
        {:ok, :in_progress} = rval -> {:cont, rval}
        _ = rval -> {:halt, rval}
      end
    end)
    |> then(fn
      {:ok, :success} ->
        if pending.final_url do
          complete(rdata, pending)
        else
          {:ok, :success}
        end

      {:ok, :in_progress} ->
        {:error, :in_progress}

      {:error, _} = err ->
        err
    end)
  end

  defp maybe_add_debug(req) do
    if Application.get_env(:porsche_conn_ex, :debug_http, false) do
      add_debug(req)
    else
      req
    end
  end

  defp add_debug(req) do
    [decompress | other_steps] =
      req.response_steps
      |> Enum.with_index()
      |> Enum.sort_by(fn
        {{:decompress_body, _}, _} -> -1
        {_, idx} -> idx
      end)
      |> Enum.map(fn {step, _} -> step end)

    %Req.Request{req | response_steps: [decompress, {:debug, &debug_dump/1} | other_steps]}
  end

  defp debug_dump({request, response}) do
    file = DateTime.utc_now() |> DateTime.to_unix(:microsecond)
    path = "/tmp/pcx/#{file}.txt"

    File.write(path, [
      inspect(request, pretty: true),
      "\n-----\n",
      inspect(response, pretty: true),
      "\n-----\n",
      response.body
    ])
    |> then(fn
      :ok -> Logger.debug("Wrote request dump to #{path}")
      err -> Logger.warning("Got #{inspect(err)} writing to #{path}")
    end)

    {request, response}
  end
end
