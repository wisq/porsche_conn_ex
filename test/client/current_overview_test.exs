defmodule PorscheConnEx.ClientCurrentOverviewTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  alias PorscheConnEx.Test.UnitFactory, as: Unit
  import PorscheConnEx.Test.Bypass

  describe "current_overview/2" do
    test "issues request, then user can wait for result", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      req_id = Data.random_request_id()
      wait_count = Enum.random(5..10)

      base_url = "/service-vehicle/de/de_DE/vehicle-data/#{vin}/current/request"

      Bypass.expect_once(bypass, "POST", base_url, fn conn ->
        resp_json(conn, ServerResponses.request_id(req_id))
      end)

      # Issue initial request:
      assert {:ok, pending} = Client.current_overview(session, vin)
      assert MockSession.count(session) == 1

      expect_status_in_progress(bypass, base_url, req_id, wait_count)

      Bypass.expect_once(bypass, "GET", "#{base_url}/#{req_id}", fn conn ->
        resp_json(conn, ServerResponses.overview(vin))
      end)

      # Wait for final status:
      expect_status_in_progress(bypass, base_url, req_id, wait_count)
      assert {:ok, overview} = Client.wait(session, pending, delay: 1)
      assert MockSession.count(session) == 2

      assert overview.vin == vin
      assert overview.car_model == "J1"
      assert overview.engine_type == "BEV"
      assert overview.mileage == Unit.distance_km_to_km(9001.0)
      assert overview.battery_level == Unit.battery_level(80)
    end
  end
end
