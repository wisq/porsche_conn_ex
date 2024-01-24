defmodule PorscheConnEx.ClientStatusTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  alias PorscheConnEx.Test.UnitFactory, as: Unit
  import PorscheConnEx.Test.Bypass

  setup do
    bypass = Bypass.open()
    {:ok, session} = MockSession.start_link()

    {:ok, bypass: bypass, session: session}
  end

  test "status", %{session: session, bypass: bypass} do
    vin = Data.random_vin()

    Bypass.expect_once(bypass, "GET", "/vehicle-data/de/de_DE/status/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.status(vin))
    end)

    assert {:ok, status} = Client.status(session, vin, Data.config(bypass))
    assert MockSession.count(session) == 1

    assert status.vin == vin
    assert status.battery_level == Unit.battery_level(80)
    assert status.mileage == Unit.distance_km_to_km(9001.0)
    assert status.overall_lock_status.locked

    assert %{electrical: elec, conventional: conv} = status.remaining_ranges
    assert elec.distance == Unit.distance_km_to_km(247.0)
    assert elec.engine_type == :electric
    assert elec.primary? == nil
    assert conv.distance == nil
    assert conv.engine_type == nil
    assert conv.primary? == nil

    assert %{"inspection" => inspect, "oilService" => oilserv} = status.service_intervals
    assert inspect.distance == Unit.distance_km_to_km(-21300.0)
    assert inspect.time == Unit.time(-113, :day)
    assert oilserv.distance == nil
    assert oilserv.time == nil

    assert status.oil_level == nil
    assert status.fuel_level == nil
  end
end