defmodule PorscheConnEx.ClientTripsShortTermTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  alias PorscheConnEx.Test.UnitFactory, as: Unit
  import PorscheConnEx.Test.Bypass

  describe "trips_short_term/2" do
    test "returns a list of recent trips", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      trip_count = Enum.random(5..50)

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/trips/#{vin}/SHORT_TERM",
        fn conn ->
          resp_json(conn, ServerResponses.trips_short_term(trip_count))
        end
      )

      assert {:ok, trips} = Client.trips_short_term(session, vin)
      assert MockSession.count(session) == 1
      assert Enum.count(trips) == trip_count

      assert first = trips |> Enum.at(0)
      assert first.end_mileage == Unit.distance_km(9001.0)

      assert trips |> Enum.all?(&(&1.type == :short_term))
      total_distance = trips |> Enum.map(& &1.distance.km) |> Enum.sum()

      assert last = trips |> Enum.at(-1)
      assert last.start_mileage == Unit.distance_km(9001.0 - total_distance)

      assert last.id < first.id
      assert DateTime.compare(last.timestamp, first.timestamp) == :lt
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(bypass, "GET", "/service-vehicle/de/de_DE/trips/#{vin}/SHORT_TERM", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.trips_short_term(session, vin)

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(
        bypass,
        "GET",
        "/service-vehicle/de/de_DE/trips/#{vin}/SHORT_TERM",
        fn conn ->
          resp_json(conn, 502, ServerResponses.unknown_502_error())
        end
      )

      assert {:error, :unknown} = Client.trips_short_term(session, vin)
    end
  end
end
