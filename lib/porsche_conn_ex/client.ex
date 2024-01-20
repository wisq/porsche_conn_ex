defmodule PorscheConnEx.Client do
  require Logger

  alias PorscheConnEx.Session
  alias PorscheConnEx.Config
  alias PorscheConnEx.Struct

  @wait_secs 120

  def vehicles(session, config \\ %Config{}) do
    get(session, config, "/core/api/v3/#{Config.url(config)}/vehicles")
    |> list_from_api(Struct.Vehicle)
  end

  def status(session, vin, config \\ %Config{}) do
    get(session, config, "/vehicle-data/#{Config.url(config)}/status/#{vin}")
    |> from_api(Struct.Status)
  end

  def summary(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/vehicle-summary/#{vin}")
    |> from_api(Struct.Summary)
  end

  def stored_overview(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/#{Config.url(config)}/vehicle-data/#{vin}/stored")
    |> from_api(Struct.Overview)
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
    |> and_wait(
      session,
      config,
      fn req_id -> "#{url}/#{req_id}/status" end,
      fn req_id -> "#{url}/#{req_id}" end
    )
    |> from_api(Struct.Overview)
  end

  def capabilities(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/vcs/capabilities/#{vin}")
  end

  def maintenance(session, vin, config \\ %Config{}) do
    get(session, config, "/predictive-maintenance/information/#{vin}")
  end

  def emobility(session, vin, model, config \\ %Config{}) do
    get(
      session,
      config,
      "/e-mobility/#{Config.url(config)}/#{model}/#{vin}",
      params: %{timezone: config.timezone}
    )
  end

  def position(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/car-finder/#{vin}/position")
  end

  def trips_short_term(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/#{Config.url(config)}/trips/#{vin}/SHORT_TERM")
  end

  def trips_long_term(session, vin, config \\ %Config{}) do
    get(session, config, "/service-vehicle/#{Config.url(config)}/trips/#{vin}/LONG_TERM")
  end

  def put_timer(session, vin, model, timer, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    put(session, config, "#{base}/timer", json: timer)
    |> and_wait(
      session,
      config,
      fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end
    )
  end

  def delete_timer(session, vin, model, timer_id, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    delete(session, config, "#{base}/timer/#{timer_id}")
    |> and_wait(
      session,
      config,
      fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end
    )
  end

  def put_profile(session, vin, model, profile, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    put(session, config, "#{base}/profile", json: profile)
    |> and_wait(
      session,
      config,
      fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end
    )
  end

  def climate_set(session, vin, climate, config \\ %Config{}) when is_boolean(climate) do
    base = "/e-mobility/#{Config.url(config)}/#{vin}/toggle-direct-climatisation"

    post(session, config, "#{base}/#{climate}", json: %{})
    |> and_wait(
      session,
      config,
      fn req_id -> "#{base}/status/#{req_id}" end
    )
  end

  defp get(session, config, url, opts \\ []) do
    req_new(session, config, url, opts)
    |> Req.get()
    |> handle()
  end

  defp post(session, config, url, opts) do
    req_new(session, config, url, opts)
    |> Req.post()
    |> handle()
  end

  defp put(session, config, url, opts) do
    req_new(session, config, url, opts)
    |> Req.put()
    |> handle()
  end

  defp delete(session, config, url, opts \\ []) do
    req_new(session, config, url, opts)
    |> Req.delete()
    |> handle()
  end

  defp and_wait(req_result, session, config, wait_url_fn, final_url_fn \\ nil)

  defp and_wait({:ok, %{"requestId" => req_id}}, s, c, w, f) do
    wait(req_id, s, c, w, f)
  end

  defp and_wait({:ok, %{"actionId" => req_id}}, s, c, w, f) do
    wait(req_id, s, c, w, f)
  end

  defp wait(req_id, session, config, wait_url_fn, final_url_fn) do
    wait_url = wait_url_fn.(req_id)
    final_url = if final_url_fn, do: final_url_fn.(req_id)

    1..@wait_secs
    |> Enum.reduce_while(nil, fn _, _ ->
      Process.sleep(config.status_delay)
      {:ok, body} = get(session, config, wait_url)

      status =
        case body do
          %{"status" => st} -> st
          %{"actionState" => st} -> st
        end

      case status do
        "IN_PROGRESS" -> {:cont, status}
        _ -> {:halt, status}
      end
    end)
    |> then(fn status ->
      if final_url do
        get(session, config, final_url)
      else
        case status do
          "SUCCESS" -> {:ok, status}
          _ -> {:error, status}
        end
      end
    end)
  end

  defp req_new(session, config, url, opts) do
    headers = Session.headers(session)

    opts
    |> Keyword.put(:url, url)
    |> Keyword.put(:base_url, config.api_url)
    |> Keyword.update(:headers, headers, &Map.merge(&1, headers))
    |> Req.new()
  end

  defp handle({:ok, %{status: status, body: body}})
       when status in [200, 202] and (is_map(body) or is_list(body)) do
    {:ok, body}
  end

  defp handle({:ok, resp}), do: {:error, resp}
  defp handle({:error, err}), do: {:error, err}

  defp from_api({:ok, body}, module) when is_map(body), do: module.load(body)

  defp list_from_api({:ok, list}, module) when is_list(list) do
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
  end
end
