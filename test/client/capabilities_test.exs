defmodule PorscheConnEx.ClientCapabilitiesTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  describe "capabilities/2" do
    test "returns vehicle capabilities", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/service-vehicle/vcs/capabilities/#{vin}", fn conn ->
        resp_json(conn, ServerResponses.capabilities())
      end)

      assert {:ok, caps} = Client.capabilities(session, vin)
      assert MockSession.count(session) == 1

      assert caps.car_model == "J1"
      assert caps.engine_type == "BEV"
      assert caps.steering_wheel == :left

      assert caps.has_rdk? == true
      assert caps.has_dx1? == false
      assert caps.needs_spin? == true
      assert caps.display_parking_brake? == true

      assert caps.heating.front_seat? == true
      assert caps.heating.rear_seat? == true
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(bypass, "GET", "/service-vehicle/vcs/capabilities/#{vin}", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.capabilities(session, vin)

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/service-vehicle/vcs/capabilities/#{vin}", fn conn ->
        resp_json(conn, 502, ServerResponses.unknown_502_error())
      end)

      assert {:error, :unknown} = Client.capabilities(session, vin)
    end
  end
end
