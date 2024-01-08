defmodule PorscheConnEx.Client do
  require Logger

  alias PorscheConnEx.Session
  alias PorscheConnEx.Config

  @api_server "api.porsche.com"

  @model_error "Failed to convert value of type 'java.lang.String' to required type 'de.porsche.myservices.emobility.dtos.vcs.CarModel'"
  @vin_error "GRAY_SLICE_ERROR_UNKNOWN_MSG"

  def vehicles(session, config \\ %Config{}) do
    Req.new(
      url: "https://#{@api_server}/core/api/v3/#{Config.url(config)}/vehicles",
      headers: Session.headers(session)
    )
    |> Req.get()
    |> handle()
  end

  def capabilities(session, vin) do
    Req.new(
      url: "https://#{@api_server}/service-vehicle/vcs/capabilities/#{vin}",
      headers: Session.headers(session)
    )
    |> with_handle_unknown_vin()
    |> Req.get()
    |> handle()
  end

  def emobility(session, vin, model, config \\ %Config{}) do
    Req.new(
      url: "https://#{@api_server}/e-mobility/#{Config.url(config)}/#{model}/#{vin}",
      params: %{timezone: config.timezone},
      headers: Session.headers(session)
    )
    |> with_handle_unknown_vin()
    |> Req.get()
    |> handle()
  end

  defp handle({:ok, %{status: 200, body: %{} = body}}), do: {:ok, body}

  defp handle({:ok, %{status: 404, body: %{"pcckErrorKey" => @vin_error}}}),
    do: {:error, :unknown_vin}

  defp handle({:ok, %{status: 400, body: %{"pcckErrorMessage" => @model_error <> _}}}),
    do: {:error, :unknown_model}

  defp handle({:ok, resp}), do: {:error, resp}
  defp handle({:error, err}), do: {:error, err}

  # Unknown VINs normally result in a 502 status, which Req thinks is a transient error.
  # This changes that to a 404 status and prevents retries.
  defp with_handle_unknown_vin(request) do
    request
    |> Req.Request.prepend_response_steps(
      handle_unknown_vin: fn
        {request, %{status: 502, body: body} = response} ->
          if String.contains?(body, @vin_error) do
            {request, %{response | status: 404}}
          else
            {request, response}
          end

        {request, response} ->
          {request, response}
      end
    )
  end
end
