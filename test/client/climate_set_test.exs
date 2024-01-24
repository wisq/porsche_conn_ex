defmodule PorscheConnEx.ClientClimateSetTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses, StatusCounter}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  setup do
    bypass = Bypass.open()
    {:ok, session} = MockSession.start_link()

    {:ok, bypass: bypass, session: session}
  end

  test "climate_set", %{session: session, bypass: bypass} do
    vin = Data.random_vin()
    req_id = Data.random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)
    enable = [true, false] |> Enum.random()

    Bypass.expect_once(
      bypass,
      "POST",
      "/e-mobility/de/de_DE/#{vin}/toggle-direct-climatisation/#{enable}",
      fn conn ->
        resp_json(conn, ServerResponses.request_id(req_id))
      end
    )

    Bypass.expect(
      bypass,
      "GET",
      "/e-mobility/de/de_DE/#{vin}/toggle-direct-climatisation/status/#{req_id}",
      fn conn ->
        resp_json(
          conn,
          case StatusCounter.tick(counter) do
            :halt -> ServerResponses.status_success()
            :cont -> ServerResponses.status_in_progress()
          end
        )
      end
    )

    assert {:ok, "SUCCESS"} = Client.climate_set(session, vin, enable, Data.config(bypass))
    assert MockSession.count(session) == status_requests + 1
  end
end
