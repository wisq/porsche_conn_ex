defmodule PorscheConnEx.Client do
  require Logger

  alias PorscheConnEx.Session
  alias PorscheConnEx.Config
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Struct.Emobility.{Timer, ChargingProfile}

  defmodule PendingRequest do
    @enforce_keys [:id, :poll_url]
    defstruct(
      id: nil,
      poll_url: nil,
      final_url: nil,
      final_handler: nil
    )
  end

  def vehicles(session, config \\ %Config{}) do
    get(session, config, "/core/api/v3/#{Config.url(config)}/vehicles")
    |> load_as_list_of(Struct.Vehicle)
  end

  def status(session, vin, config \\ %Config{}) do
    get(session, config, "/vehicle-data/#{Config.url(config)}/status/#{vin}")
    |> load_as(Struct.Status)
  end

  def summary(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/vehicle-summary/#{vin}")
    |> load_as(Struct.Summary)
  end

  def stored_overview(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/#{Config.url(config)}/vehicle-data/#{vin}/stored")
    |> load_as(Struct.Overview)
  end

  def current_overview(session, vin, config \\ %Config{}) do
    url = "/service-vehicle/#{Config.url(config)}/vehicle-data/#{vin}/current/request"

    post(
      session,
      config,
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

  def capabilities(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/vcs/capabilities/#{vin}")
    |> load_as(Struct.Capabilities)
  end

  def maintenance(session, vin, config \\ %Config{}) do
    get(session, config, "/predictive-maintenance/information/#{vin}")
    |> load_as(Struct.Maintenance)
  end

  def emobility(session, vin, model, config \\ %Config{}) do
    get(
      session,
      config,
      "/e-mobility/#{Config.url(config)}/#{model}/#{vin}",
      params: %{timezone: config.timezone}
    )
    |> load_as(Struct.Emobility)
  end

  def position(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/car-finder/#{vin}/position")
    |> load_as(Struct.Position)
  end

  def trips_short_term(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/#{Config.url(config)}/trips/#{vin}/SHORT_TERM")
    |> load_as_list_of(Struct.Trip)
  end

  def trips_long_term(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/#{Config.url(config)}/trips/#{vin}/LONG_TERM")
    |> load_as_list_of(Struct.Trip)
  end

  def put_timer(session, vin, model, timer, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    with {:ok, timer_json} <- Timer.dump(timer) do
      put(session, config, "#{base}/timer", json: timer_json)
      |> as_pending(poll_url: fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end)
    end
  end

  def delete_timer(session, vin, model, timer_id, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    delete(session, config, "#{base}/timer/#{timer_id}")
    |> as_pending(poll_url: fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end)
  end

  def put_charging_profile(session, vin, model, profile, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    with {:ok, profile_json} <- ChargingProfile.dump(profile) do
      put(session, config, "#{base}/profile", json: profile_json)
      |> as_pending(poll_url: fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end)
    end
  end

  def climate_set(session, vin, climate, config \\ %Config{}) when is_boolean(climate) do
    base = "/e-mobility/#{Config.url(config)}/#{vin}/toggle-direct-climatisation"

    post(session, config, "#{base}/#{climate}", json: %{})
    |> as_pending(poll_url: fn req_id -> "#{base}/status/#{req_id}" end)
  end

  defp get(session, config, url, opts \\ []) do
    req_new(session, config, url, opts)
    |> Req.get()
  end

  defp post(session, config, url, opts) do
    req_new(session, config, url, opts)
    |> Req.post()
  end

  defp put(session, config, url, opts) do
    req_new(session, config, url, opts)
    |> Req.put()
  end

  defp delete(session, config, url, opts \\ []) do
    req_new(session, config, url, opts)
    |> Req.delete()
  end

  defp req_new(session, config, url, opts) do
    headers = Session.headers(session)

    opts
    |> Keyword.merge(
      url: url,
      base_url: config.api_url,
      receive_timeout: config.receive_timeout,
      max_retries: config.max_retries
    )
    |> Keyword.update(:headers, headers, &Map.merge(&1, headers))
    |> Req.new()
    |> maybe_add_debug()
  end

  defp handle_response({:ok, %{status: status, body: body}}, fun), do: fun.(status, body)
  # transport error
  defp handle_response({:error, %{reason: reason}}, _), do: {:error, reason}
  # unknown error
  defp handle_response({:error, _}, _), do: {:error, :unknown}

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

  def poll(session, %PendingRequest{} = pending, config \\ %Config{}) do
    get(session, config, pending.poll_url)
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

  def complete(session, %PendingRequest{} = pending, config \\ %Config{}) do
    get(session, config, pending.final_url)
    |> pending.final_handler.()
  end

  def wait(
        session,
        %PendingRequest{} = pending,
        opts \\ [],
        config \\ %Config{}
      ) do
    wait_count = Keyword.get(opts, :count, 120)
    wait_delay = Keyword.get(opts, :delay, 1000)

    1..wait_count//1
    |> Enum.reduce_while({:ok, :in_progress}, fn _, _ ->
      Process.sleep(wait_delay)

      case poll(session, pending, config) do
        {:ok, :in_progress} = rval -> {:cont, rval}
        _ = rval -> {:halt, rval}
      end
    end)
    |> then(fn
      {:ok, :success} ->
        if pending.final_url do
          complete(session, pending, config)
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
