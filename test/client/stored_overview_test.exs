defmodule PorscheConnEx.ClientStoredOverviewTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  alias PorscheConnEx.Test.UnitFactory, as: Unit
  import PorscheConnEx.Test.Bypass

  describe "stored_overview/2" do
    test "returns vehicle overview, with tire data", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
        fn conn ->
          resp_json(conn, ServerResponses.overview(vin, true))
        end
      )

      assert {:ok, overview} = Client.stored_overview(session, vin)
      assert MockSession.count(session) == 1

      assert overview.vin == vin
      assert overview.car_model == "J1"
      assert overview.engine_type == "BEV"
      assert overview.mileage == Unit.distance_km(9001.0)
      assert overview.battery_level == Unit.battery_level(80)
      assert overview.charging_state == :completed
      assert overview.charging_status == :completed

      assert overview.doors.front_left == lock(:closed, :locked)
      assert overview.doors.front_right == lock(:closed, :locked)
      assert overview.doors.back_left == lock(:closed, :locked)
      assert overview.doors.back_right == lock(:closed, :locked)
      assert overview.doors.trunk == lock(:closed, :locked)
      assert overview.doors.hood == lock(:closed, :unlocked)
      assert overview.doors.overall == lock(:closed, :locked)

      assert overview.windows.front_left == :closed
      assert overview.windows.front_right == :closed
      assert overview.windows.back_left == :closed
      assert overview.windows.back_right == :closed
      assert overview.windows.maintenance_hatch == nil
      assert overview.windows.roof == nil
      assert overview.windows.sunroof.position == nil
      assert overview.windows.sunroof.status == nil

      assert overview.tires.front_left == Unit.tire_pressure(2.4, 2.7, 0.3, :divergent)
      assert overview.tires.front_right == Unit.tire_pressure(2.4, 2.7, 0.3, :divergent)
      assert overview.tires.back_left == Unit.tire_pressure(2.3, 2.5, 0.2, :divergent)
      assert overview.tires.back_right == Unit.tire_pressure(2.3, 2.4, 0.1, :divergent)

      assert overview.open? == false
      assert overview.parking_brake? == false
      assert overview.parking_brake_status == nil
      assert overview.parking_light == :off
      assert overview.parking_light_status == nil
      assert overview.parking_time == ~U[2024-01-17 21:48:10Z]

      assert %{electric: elec, conventional: conv} = overview.remaining_ranges
      assert elec.distance == Unit.distance_km(247.0)
      assert elec.engine_type == :electric
      assert elec.primary? == true
      assert conv.distance == nil
      assert conv.engine_type == nil
      assert conv.primary? == false

      assert %{"inspection" => inspect, "oilService" => nil} = overview.service_intervals
      assert inspect.distance == Unit.distance_km(-21300.0)
      assert inspect.time == Unit.time(-113, :day)

      assert overview.oil_level == nil
      assert overview.fuel_level == nil
    end

    test "returns vehicle overview, without tire data", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
        fn conn ->
          resp_json(conn, ServerResponses.overview(vin, false))
        end
      )

      assert {:ok, overview} = Client.stored_overview(session, vin)
      assert MockSession.count(session) == 1

      nil_tire = %Struct.Overview.TirePressure{
        current: nil,
        optimal: nil,
        difference: nil,
        status: nil
      }

      assert overview.vin == vin
      assert overview.tires.front_left == nil_tire
      assert overview.tires.front_right == nil_tire
      assert overview.tires.back_left == nil_tire
      assert overview.tires.back_right == nil_tire
    end

    test "returns vehicle overview, with imperial units", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
        fn conn ->
          resp_json(conn, ServerResponses.overview_US(vin))
        end
      )

      assert {:ok, overview} = Client.stored_overview(session, vin)
      assert MockSession.count(session) == 1

      assert overview.vin == vin
      assert overview.car_model == "J1"
      assert overview.engine_type == "BEV"
      assert overview.mileage == Unit.distance_miles(5533.31, 8905.0)
      assert overview.battery_level == Unit.battery_level(80)
      assert overview.charging_state == :completed
      assert overview.charging_status == :completed

      assert overview.doors.front_left == lock(:closed, :locked)
      assert overview.doors.front_right == lock(:closed, :locked)
      assert overview.doors.back_left == lock(:closed, :locked)
      assert overview.doors.back_right == lock(:closed, :locked)
      assert overview.doors.trunk == lock(:closed, :locked)
      assert overview.doors.hood == lock(:closed, :unlocked)
      assert overview.doors.overall == lock(:closed, :locked)

      assert overview.windows.front_left == :closed
      assert overview.windows.front_right == :closed
      assert overview.windows.back_left == :closed
      assert overview.windows.back_right == :closed
      assert overview.windows.maintenance_hatch == nil
      assert overview.windows.roof == nil
      assert overview.windows.sunroof.position == nil
      assert overview.windows.sunroof.status == nil

      tires = overview.tires
      assert tires.front_left == Unit.tire_pressure_psi(36.25943, 40.61057, 4.351132, :divergent)
      assert tires.front_right == Unit.tire_pressure_psi(36.25943, 40.61057, 4.351132, :divergent)
      assert tires.back_left == Unit.tire_pressure_psi(34.80906, 37.70981, 2.900755, :divergent)
      assert tires.back_right == Unit.tire_pressure_psi(34.80906, 37.70981, 2.900755, :divergent)

      assert overview.open? == false
      assert overview.parking_brake? == true
      assert overview.parking_brake_status == nil
      assert overview.parking_light == :off
      assert overview.parking_light_status == nil
      assert overview.parking_time == ~U[2024-01-28 08:42:37Z]

      assert %{electric: elec, conventional: conv} = overview.remaining_ranges
      assert elec.distance == Unit.distance_miles(159.6924, 257.0)
      assert elec.engine_type == :electric
      assert elec.primary? == true
      assert conv.distance == nil
      assert conv.engine_type == nil
      assert conv.primary? == false

      assert %{"inspection" => inspect, "oilService" => nil} = overview.service_intervals
      assert inspect.distance == Unit.distance_miles(-13173.07, -21200.0)
      assert inspect.time == Unit.time(-103, :day)

      assert overview.oil_level == nil
      assert overview.fuel_level == nil
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
        fn _ -> Process.sleep(5000) end
      )

      assert {:error, :timeout} = Client.stored_overview(session, vin)

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
        fn conn ->
          resp_json(conn, 502, ServerResponses.unknown_502_error())
        end
      )

      assert {:error, :unknown} = Client.stored_overview(session, vin)
    end
  end

  def lock(open, locked) do
    %Struct.Status.LockStatus{
      open?:
        case open do
          :open -> true
          :closed -> false
        end,
      locked?:
        case locked do
          :locked -> true
          :unlocked -> false
        end
    }
  end
end
