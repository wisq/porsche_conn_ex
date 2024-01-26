defmodule PorscheConnEx.ClientCapabilitiesTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  test "capabilities", %{session: session, bypass: bypass} do
    vin = Data.random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vcs/capabilities/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.capabilities())
    end)

    assert {:ok, caps} = Client.capabilities(session, vin, Data.config(bypass))
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
end
