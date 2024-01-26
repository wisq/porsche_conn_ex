defmodule PorscheConnEx.ClientEmobliityTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  alias PorscheConnEx.Test.UnitFactory, as: Unit
  import PorscheConnEx.Test.Bypass

  setup do
    tz = Data.random_timezone()
    bypass = Bypass.open()

    {:ok, session} =
      PorscheConnEx.Test.MockSession.start_link(
        config: PorscheConnEx.Test.DataFactory.config(bypass, timezone: tz)
      )

    {:ok, bypass: bypass, session: session, tz: tz}
  end

  describe "Client.emobility/3" do
    test "fetches emobility data", %{session: session, bypass: bypass, tz: tz} do
      vin = Data.random_vin()
      model = Data.random_model()

      Bypass.expect_once(bypass, "GET", "/e-mobility/de/de_DE/#{model}/#{vin}", fn conn ->
        assert %{"timezone" => ^tz} = conn.query_params
        resp_json(conn, ServerResponses.emobility())
      end)

      assert {:ok, emobility} = Client.emobility(session, vin, model)
      assert MockSession.count(session) == 1

      assert charging = emobility.charging
      assert charging.mode == :off
      assert charging.plug == :connected
      assert charging.plug_lock == :locked
      assert charging.state == :completed
      assert charging.reason == {:timer, 4}
      assert charging.external_power == :station_connected
      assert charging.led_color == :green
      assert charging.led_state == :solid
      assert charging.percent == 80
      assert charging.minutes_to_full == 0
      assert charging.remaining_electric_range == Unit.distance_km_to_km(248)
      assert charging.remaining_conventional_range == nil
      assert charging.target_time == ~N[2024-01-17 19:55:00]
      assert charging.target_opl_enforced == nil
      assert charging.rate == Unit.charge_rate(0, 0)
      assert charging.kilowatts == 0
      assert charging.dc_mode? == false

      assert emobility.direct_charge.disabled? == false
      assert emobility.direct_charge.active? == false

      assert climate = emobility.direct_climate
      assert climate.state == :off
      assert climate.remaining_minutes == nil
      assert climate.target_temperature == Unit.temperature(2930, 20)
      assert climate.without_hv_power == false
      assert climate.heater_source == :electric

      assert [first, _, _, _, last] = emobility.timers

      assert first.id == 1
      assert first.active? == true
      assert first.depart_time == ~N[2024-01-20 18:41:00]
      assert first.climate? == true
      assert first.charge? == false
      assert first.repeating? == false
      assert first.weekdays == nil
      assert first.target_charge == 85

      assert last.id == 5
      assert last.active? == true
      assert last.depart_time == ~N[2024-01-17 07:00:00]
      assert last.climate? == false
      assert last.charge? == true
      assert last.repeating? == true
      assert last.weekdays == [1, 2, 3, 4, 5, 6, 7]
      assert last.target_charge == 80

      assert emobility.current_charging_profile_id == 5
      assert Enum.count(emobility.charging_profiles) == 2
      assert [%{id: 4} = profile4, %{id: 5} = profile5] = emobility.charging_profiles

      assert profile4.id == 4
      assert profile4.name == "Allgemein"
      assert profile4.active == true
      assert profile4.charging.minimum_charge == 30
      assert profile4.charging.target_charge == 100
      assert profile4.charging.mode == :smart
      assert profile4.charging.preferred_time_start == ~T[19:00:00]
      assert profile4.charging.preferred_time_end == ~T[07:00:00]
      assert profile4.position == nil

      assert profile5.id == 5
      assert profile5.name == "Home"
      assert profile5.active == true
      assert profile5.charging.minimum_charge == 30
      assert profile5.charging.target_charge == 100
      assert profile5.charging.mode == :preferred_time
      assert profile5.charging.preferred_time_start == ~T[19:00:00]
      assert profile5.charging.preferred_time_end == ~T[07:00:00]
      assert profile5.position.latitude == 45.444444
      assert profile5.position.longitude == -75.693889
      assert profile5.position.radius == 250
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      model = Data.random_model()

      Bypass.stub(bypass, "GET", "/e-mobility/de/de_DE/#{model}/#{vin}", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.emobility(session, vin, model)

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      model = Data.random_model()

      Bypass.expect_once(bypass, "GET", "/e-mobility/de/de_DE/#{model}/#{vin}", fn conn ->
        resp_json(conn, 502, ServerResponses.unknown_502_error())
      end)

      assert {:error, :unknown} = Client.emobility(session, vin, model)
    end
  end
end
