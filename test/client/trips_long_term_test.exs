defmodule PorscheConnEx.ClientTripsLongTermTest do
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

  describe "Client.trips_long_term/2" do
    test "trips_long_term", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/trips/#{vin}/LONG_TERM",
        fn conn ->
          resp_json(conn, ServerResponses.trips_long_term())
        end
      )

      assert {:ok, trips} = Client.trips_long_term(session, vin, Data.config(bypass))
      assert MockSession.count(session) == 1
      assert [first, second] = trips

      assert first.id == 2_627_363_506
      assert first.type == :long_term
      assert first.timestamp == ~U[2024-01-01 01:02:03Z]
      assert first.minutes == 3479
      assert first.average_speed == Unit.speed_kmh(31.0)
      assert first.zero_emission_distance == Unit.distance_km_to_km(1759.0)
      assert first.average_fuel_consumption == Unit.fuel_consumption_km(0.0)
      assert first.average_energy_consumption == Unit.energy_consumption_km(32.7)

      assert second.id == 2_586_922_833
      assert second.type == :long_term
      assert second.timestamp == ~U[2023-12-08 23:45:25Z]
      assert second.minutes == 10415
      assert second.average_speed == Unit.speed_kmh(42.0)
      assert second.zero_emission_distance == Unit.distance_km_to_km(7242.0)
      assert second.average_fuel_consumption == Unit.fuel_consumption_km(0.0)
      assert second.average_energy_consumption == Unit.energy_consumption_km(9.5)

      assert first.end_mileage == Unit.distance_km_to_km(9001.0)
      assert first.start_mileage == Unit.distance_km_to_km(7242.0)
      assert second.end_mileage == Unit.distance_km_to_km(7242.0)
      assert second.start_mileage == Unit.distance_km_to_km(0.0)
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(bypass, "GET", "/service-vehicle/de/de_DE/trips/#{vin}/LONG_TERM", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.trips_long_term(session, vin, Data.config(bypass))

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

      assert {:error, :unknown} = Client.trips_long_term(session, vin, Data.config(bypass))
    end
  end
end
