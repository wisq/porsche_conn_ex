defmodule PorscheConnEx.ClientCurrentOverviewTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses, StatusCounter}
  alias PorscheConnEx.Test.DataFactory, as: Data
  alias PorscheConnEx.Test.UnitFactory, as: Unit
  import PorscheConnEx.Test.Bypass

  setup do
    bypass = Bypass.open()
    {:ok, session} = MockSession.start_link()

    {:ok, bypass: bypass, session: session}
  end

  test "current_overview", %{session: session, bypass: bypass} do
    vin = Data.random_vin()
    req_id = Data.random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)

    Bypass.expect_once(
      bypass,
      "POST",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/current/request",
      fn conn ->
        resp_json(conn, ServerResponses.request_id(req_id))
      end
    )

    Bypass.expect(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/current/request/#{req_id}/status",
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

    Bypass.expect_once(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/current/request/#{req_id}",
      fn conn ->
        resp_json(conn, ServerResponses.overview(vin))
      end
    )

    assert {:ok, overview} = Client.current_overview(session, vin, Data.config(bypass))
    assert MockSession.count(session) == status_requests + 2
    assert StatusCounter.get(counter) == 0

    assert overview.vin == vin
    assert overview.car_model == "J1"
    assert overview.engine_type == "BEV"
    assert overview.mileage == Unit.distance_km_to_km(9001.0)
    assert overview.battery_level == Unit.battery_level(80)
  end
end
