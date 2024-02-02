defmodule PorscheConnEx.ClientTripsLongTermTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  alias PorscheConnEx.Test.UnitFactory, as: Unit
  import PorscheConnEx.Test.Bypass

  describe "Client.trips_long_term/2" do
    test "returns a list of long-term trip epochs", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/trips/#{vin}/LONG_TERM",
        fn conn ->
          resp_json(conn, ServerResponses.trips_long_term())
        end
      )

      assert {:ok, trips} = Client.trips_long_term(session, vin)
      assert MockSession.count(session) == 1
      assert [first, second] = trips

      assert first.id == 2_627_363_506
      assert first.type == :long_term
      assert first.timestamp == ~U[2024-01-01 01:02:03Z]
      assert first.minutes == 3479
      assert first.average_speed == Unit.speed_kmh(31.0)
      assert first.zero_emission_distance == Unit.distance_km(1759.0)
      assert first.average_fuel_consumption == Unit.fuel_consumption_km(0.0)
      assert first.average_energy_consumption == Unit.energy_consumption_km(32.7)

      assert second.id == 2_586_922_833
      assert second.type == :long_term
      assert second.timestamp == ~U[2023-12-08 23:45:25Z]
      assert second.minutes == 10415
      assert second.average_speed == Unit.speed_kmh(42.0)
      assert second.zero_emission_distance == Unit.distance_km(7242.0)
      assert second.average_fuel_consumption == Unit.fuel_consumption_km(0.0)
      assert second.average_energy_consumption == Unit.energy_consumption_km(9.5)

      assert first.end_mileage == Unit.distance_km(9001.0)
      assert first.start_mileage == Unit.distance_km(7242.0)
      assert second.end_mileage == Unit.distance_km(7242.0)
      assert second.start_mileage == Unit.distance_km(0.0)
    end

    test "handles US/imperial units", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/trips/#{vin}/LONG_TERM",
        fn conn ->
          resp_json(conn, ServerResponses.trips_long_term_US())
        end
      )

      assert {:ok, trips} = Client.trips_long_term(session, vin)
      assert MockSession.count(session) == 1
      assert [first, second] = trips

      assert first.id == 2_140_611_149
      assert first.type == :long_term
      assert first.timestamp == ~U[2024-02-01 22:20:07Z]
      assert first.minutes == 4241
      assert first.average_speed == Unit.speed_mph(18.01976, 28.99999)
      assert first.zero_emission_distance == Unit.distance_miles(1262.626, 2032.0)
      assert first.average_fuel_consumption == Unit.fuel_consumption_mpg(0.0, 0.0)
      assert first.average_energy_consumption == Unit.energy_consumption_mi(1.877254, 33.10001)

      assert second.id == 2_140_211_878
      assert second.type == :long_term
      assert second.timestamp == ~U[2023-12-08 23:45:25Z]
      assert second.minutes == 10415
      assert second.average_speed == Unit.speed_mph(25.47622, 41.0)
      assert second.zero_emission_distance == Unit.distance_miles(4347.734, 6997.0)
      assert second.average_fuel_consumption == Unit.fuel_consumption_mpg(0.0, 0.0)
      assert second.average_energy_consumption == Unit.energy_consumption_mi(6.540749, 9.500001)

      assert first.end_mileage == Unit.distance_miles(5610.36, 9029.0)
      assert first.start_mileage == Unit.distance_miles(4347.734, 6997.0)
      assert second.end_mileage == Unit.distance_miles(4347.734, 6997.0)
      assert second.start_mileage == Unit.distance_miles(0.0, 0.0)
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(bypass, "GET", "/service-vehicle/de/de_DE/trips/#{vin}/LONG_TERM", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.trips_long_term(session, vin)

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/trips/#{vin}/LONG_TERM",
        fn conn ->
          resp_json(conn, 502, ServerResponses.unknown_502_error())
        end
      )

      assert {:error, :unknown} = Client.trips_long_term(session, vin)
    end
  end
end
