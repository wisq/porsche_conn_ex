defmodule PorscheConnEx.Client do
  require Logger

  alias PorscheConnEx.Session
  alias PorscheConnEx.Config

  @wait_secs 120

  def vehicles(session, config \\ %Config{}) do
    get(session, "/core/api/v3/#{Config.url(config)}/vehicles")
  end

  def status(session, vin, config \\ %Config{}) do
    get(session, "/vehicle-data/#{Config.url(config)}/status/#{vin}")
  end

  def summary(session, vin) do
    get(session, "/service-vehicle/vehicle-summary/#{vin}")
  end

  def stored_overview(session, vin, config \\ %Config{}) do
    get(session, "/service-vehicle/#{Config.url(config)}/vehicle-data/#{vin}/stored")
  end

  def current_overview(session, vin, config \\ %Config{}) do
    url = "/service-vehicle/#{Config.url(config)}/vehicle-data/#{vin}/current/request"

    post(
      session,
      url,
      # avoids "missing content-length" error
      body: ""
    )
    |> and_wait(
      session,
      fn req_id -> "#{url}/#{req_id}/status" end,
      fn req_id -> "#{url}/#{req_id}" end
    )
  end

  def capabilities(session, vin) do
    get(session, "/service-vehicle/vcs/capabilities/#{vin}")
  end

  def maintenance(session, vin) do
    get(session, "/predictive-maintenance/information/#{vin}")
  end

  def emobility(session, vin, model, config \\ %Config{}) do
    get(
      session,
      "/e-mobility/#{Config.url(config)}/#{model}/#{vin}",
      params: %{timezone: config.timezone}
    )
  end

  def position(session, vin) do
    get(session, "/service-vehicle/car-finder/#{vin}/position")
  end

  def trips_short_term(session, vin, config \\ %Config{}) do
    get(session, "/service-vehicle/#{Config.url(config)}/trips/#{vin}/SHORT_TERM")
  end

  def trips_long_term(session, vin, config \\ %Config{}) do
    get(session, "/service-vehicle/#{Config.url(config)}/trips/#{vin}/LONG_TERM")
  end

  def put_timer(session, vin, model, timer, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    put(session, "#{base}/timer", json: timer)
    |> and_wait(
      session,
      fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end
    )
  end

  def delete_timer(session, vin, model, timer_id, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    delete(session, "#{base}/timer/#{timer_id}")
    |> and_wait(
      session,
      fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end
    )
  end

  def put_profile(session, vin, model, profile, config \\ %Config{}) do
    base = "/e-mobility/#{Config.url(config)}/#{model}/#{vin}"

    put(session, "#{base}/profile", json: profile)
    |> and_wait(
      session,
      fn req_id -> "#{base}/action-status/#{req_id}?hasDX1=false" end
    )
  end

  def climate_set(session, vin, climate, config \\ %Config{}) when is_boolean(climate) do
    base = "/e-mobility/#{Config.url(config)}/#{vin}/toggle-direct-climatisation"

    post(session, "#{base}/#{climate}", json: %{})
    |> and_wait(
      session,
      fn req_id -> "#{base}/status/#{req_id}" end
    )
  end

  defp get(session, url, opts \\ []) do
    req_new(session, url, opts)
    |> Req.get()
    |> handle()
  end

  defp post(session, url, opts) do
    req_new(session, url, opts)
    |> Req.post()
    |> handle()
  end

  defp put(session, url, opts) do
    req_new(session, url, opts)
    |> Req.put()
    |> handle()
  end

  defp delete(session, url, opts \\ []) do
    req_new(session, url, opts)
    |> Req.delete()
    |> handle()
  end

  defp and_wait(req_result, session, wait_url_fn, final_url_fn \\ nil)

  defp and_wait({:ok, %{"requestId" => req_id}}, s, w, f) do
    wait(req_id, s, w, f)
  end

  defp and_wait({:ok, %{"actionId" => req_id}}, s, w, f) do
    wait(req_id, s, w, f)
  end

  defp wait(req_id, session, wait_url_fn, final_url_fn) do
    wait_url = wait_url_fn.(req_id)
    final_url = if final_url_fn, do: final_url_fn.(req_id)

    1..@wait_secs
    |> Enum.reduce_while(nil, fn _, _ ->
      {:ok, body} = get(session, wait_url)

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
        get(session, final_url)
      else
        case status do
          "SUCCESS" -> {:ok, status}
          _ -> {:error, status}
        end
      end
    end)
  end

  defp req_new(session, url, opts) do
    headers = Session.headers(session)

    opts
    |> Keyword.put(:url, "https://api.porsche.com/#{url}")
    |> Keyword.update(:headers, headers, &Map.merge(&1, headers))
    |> Req.new()
  end

  defp handle({:ok, %{status: status, body: body}})
       when status in [200, 202] and (is_map(body) or is_list(body)) do
    {:ok, body}
  end

  defp handle({:ok, resp}), do: {:error, resp}
  defp handle({:error, err}), do: {:error, err}
end
