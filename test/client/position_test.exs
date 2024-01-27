defmodule PorscheConnEx.ClientPositionTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  describe "position/2" do
    test "returns vehicle position", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/service-vehicle/car-finder/#{vin}/position", fn conn ->
        resp_json(conn, ServerResponses.position())
      end)

      assert {:ok, position} = Client.position(session, vin)
      assert MockSession.count(session) == 1

      assert position.coordinates.latitude == 45.444444
      assert position.coordinates.longitude == -75.693889
      assert position.coordinates.reference_system == :wgs84
      assert position.heading == 90
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(bypass, "GET", "/service-vehicle/car-finder/#{vin}/position", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.position(session, vin)

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/service-vehicle/car-finder/#{vin}/position", fn conn ->
        resp_json(conn, 502, ServerResponses.unknown_502_error())
      end)

      assert {:error, :unknown} = Client.position(session, vin)
    end
  end
end
