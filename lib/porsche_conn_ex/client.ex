defmodule PorscheConnEx.Client do
  require Logger

  alias PorscheConnEx.Session
  alias PorscheConnEx.Config

  @wait_secs 120

  def vehicles(session, config \\ %Config{}) do
    get(session, "/core/api/v3/#{Config.url(config)}/vehicles")
  end

  def summary(session, vin) do
    get(session, "/service-vehicle/vehicle-summary/#{vin}")
  end

  def stored_overview(session, vin, config \\ %Config{}) do
    get(session, "/service-vehicle/#{Config.url(config)}/vehicle-data/#{vin}/stored")
  end

  def current_overview(session, vin, config \\ %Config{}) do
    url = "/service-vehicle/#{Config.url(config)}/vehicle-data/#{vin}/current/request"

    post_and_wait(
      session,
      url,
      fn req_id -> "#{url}/#{req_id}/status" end,
      fn req_id -> "#{url}/#{req_id}" end,
      # avoids "missing content-length" error
      body: ""
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

  defp post_and_wait(session, url, wait_url_fn, final_url_fn, opts) do
    case post(session, url, opts) do
      {:ok, %{"requestId" => req_id}} ->
        1..@wait_secs
        |> Enum.reduce_while(nil, fn _, _ ->
          continue =
            case get(session, wait_url_fn.(req_id)) do
              {:ok, %{"status" => status}} -> status == "IN_PROGRESS"
              {:ok, %{"actionState" => status}} -> status == "IN_PROGRESS"
            end

          {if(continue, do: :cont, else: :halt), nil}
        end)

        get(session, final_url_fn.(req_id))
    end
  end

  defp req_new(session, url, opts) do
    headers = Session.headers(session)

    opts
    |> Keyword.put(:url, "https://api.porsche.com/#{url}")
    |> Keyword.update(:headers, headers, &Map.merge(&1, headers))
    |> Req.new()
  end

  defp handle({:ok, %{status: 200, body: %{} = body}}), do: {:ok, body}
  defp handle({:ok, resp}), do: {:error, resp}
  defp handle({:error, err}), do: {:error, err}
end
