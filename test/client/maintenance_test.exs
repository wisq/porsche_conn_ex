defmodule PorscheConnEx.ClientMaintenanceTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  describe "maintenance/2" do
    test "returns a list of maintenance items", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/predictive-maintenance/information/#{vin}", fn conn ->
        resp_json(conn, ServerResponses.maintenance())
      end)

      assert {:ok, maint} = Client.maintenance(session, vin)
      assert MockSession.count(session) == 1

      assert maint.service_access? == true
      assert Enum.count(maint.schedule) == 13

      assert first = Enum.at(maint.schedule, 0)
      assert first.id == "0003"
      assert first.description.short_name == "Inspektion"
      assert first.description.long_name == nil
      assert first.description.criticality == "Zurzeit ist kein Service notwendig."
      assert first.description.notification == nil
      assert first.criticality == 1
      assert first.remaining_days == nil
      assert first.remaining_km == nil
      assert first.remaining_percent == nil

      assert first.values.model_id == "0003"
      assert first.values.model_state == :active
      assert first.values.model_name == "Service-Intervall"
      assert first.values.model_visibility == :visible
      assert first.values.source == :vehicle
      assert first.values.event == :cyclic
      assert first.values.odometer_last_reset == 0
      assert first.values.criticality == 1
      assert first.values.warnings == %{99 => 0, 100 => 0}

      assert last = Enum.at(maint.schedule, -1)
      assert last.id == "0037"
      assert last.description.short_name == "On-Board DC-Lader"
      assert last.description.long_name == "On-Board DC-Lader"
      assert last.description.criticality == "Zurzeit ist kein Service notwendig."
      assert last.description.notification == nil
      assert last.criticality == 1
      assert last.remaining_days == nil
      assert last.remaining_km == nil
      assert last.remaining_percent == nil

      assert last.values.model_id == "0037"
      assert last.values.model_state == :active
      assert last.values.model_name == "HV_Booster"
      assert last.values.model_visibility == :visible
      assert last.values.source == :vehicle
      assert last.values.event == :cyclic
      assert last.values.odometer_last_reset == 0
      assert last.values.criticality == 1
      assert last.values.warnings == %{}
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(bypass, "GET", "/predictive-maintenance/information/#{vin}", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.maintenance(session, vin)

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/predictive-maintenance/information/#{vin}", fn conn ->
        # Note: Different 502 error body than most requests.
        resp_json(conn, 502, ServerResponses.service_access_502_error())
      end)

      assert {:error, :unknown} = Client.maintenance(session, vin)
    end
  end
end
