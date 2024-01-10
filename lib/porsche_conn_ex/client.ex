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

  defp and_wait({:ok, %{"requestId" => req_id}}, session, wait_url_fn, final_url_fn) do
    1..@wait_secs
    |> Enum.reduce_while(nil, fn _, _ ->
      {:ok, %{"status" => status}} = get(session, wait_url_fn.(req_id))
      {if(status == "IN_PROGRESS", do: :cont, else: :halt), nil}
    end)

    get(session, final_url_fn.(req_id))
  end

  defp and_wait({:ok, %{"actionId" => req_id}}, session, wait_url_fn) do
    1..@wait_secs
    |> Enum.reduce_while(nil, fn _, _ ->
      {:ok, %{"actionState" => status}} = get(session, wait_url_fn.(req_id))

      case status do
        "IN_PROGRESS" -> {:cont, status}
        _ -> {:halt, status}
      end
    end)
    |> then(fn
      "SUCCESS" -> {:ok, "SUCCESS"}
      other -> {:error, other}
    end)
  end

  defp req_new(session, url, opts) do
    headers = Session.headers(session)

    opts
    |> Keyword.put(:url, "https://api.porsche.com/#{url}")
    |> Keyword.update(:headers, headers, &Map.merge(&1, headers))
    |> Req.new()
  end

  defp handle({:ok, %{status: 200, body: body}}) when is_map(body) or is_list(body) do
    {:ok, body}
  end

  defp handle({:ok, resp}), do: {:error, resp}
  defp handle({:error, err}), do: {:error, err}
end
