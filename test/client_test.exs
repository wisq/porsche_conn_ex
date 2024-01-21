defmodule PorscheConnEx.ClientTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Config
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Test.{MockSession, ServerResponses, StatusCounter}
  alias Plug.Conn

  setup do
    bypass = Bypass.open()
    {:ok, session} = MockSession.start_link()

    {:ok, bypass: bypass, session: session}
  end

  test "vehicles", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/core/api/v3/de/de_DE/vehicles", fn conn ->
      resp_json(conn, ServerResponses.vehicles(vin))
    end)

    assert {:ok, [vehicle]} = Client.vehicles(session, config(bypass))
    assert MockSession.count(session) == 1

    assert vehicle.vin == vin
    assert vehicle.model_year == 2022
    assert vehicle.model_type == "Y1ADE1"
    assert vehicle.model_description == "Taycan GTS"
    assert vehicle.relationship == "OWNER"
    assert vehicle.login_method == "PORSCHE_ID"
    assert vehicle.exterior_color == "vulkangraumetallic/vulkangraumetallic"
    assert vehicle.exterior_color_hex == "#252625"
    assert vehicle.attributes == []

    assert vehicle.valid_from == ~U[2024-01-01 01:02:03.000Z]
    assert vehicle.pending_relationship_termination_at == nil

    assert vehicle.pcc? == true
    assert vehicle.spin_enabled? == true
    assert vehicle.ota_active? == true
  end

  test "vehicles with nickname", %{session: session, bypass: bypass} do
    vin = random_vin()
    nickname = random_nickname()

    Bypass.expect_once(bypass, "GET", "/core/api/v3/de/de_DE/vehicles", fn conn ->
      resp_json(conn, ServerResponses.vehicles(vin, nickname))
    end)

    assert {:ok, [%Struct.Vehicle{} = vehicle]} = Client.vehicles(session, config(bypass))
    assert MockSession.count(session) == 1

    assert vehicle.vin == vin
    assert [%{name: "licenseplate", value: ^nickname}] = vehicle.attributes
  end

  test "status", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/vehicle-data/de/de_DE/status/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.status(vin))
    end)

    assert {:ok, status} = Client.status(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert status.vin == vin
    assert status.battery_level == battery_level(80)
    assert status.mileage == distance_km_to_km(9001.0)
    assert status.overall_lock_status.locked

    assert %{electrical: elec, conventional: conv} = status.remaining_ranges
    assert elec.distance == distance_km_to_km(247.0)
    assert elec.engine_type == :electric
    assert elec.primary? == nil
    assert conv.distance == nil
    assert conv.engine_type == nil
    assert conv.primary? == nil

    assert %{"inspection" => inspect, "oilService" => oilserv} = status.service_intervals
    assert inspect.distance == distance_km_to_km(-21300.0)
    assert inspect.time == time(-113, :day)
    assert oilserv.distance == nil
    assert oilserv.time == nil

    assert status.oil_level == nil
    assert status.fuel_level == nil
  end

  test "summary", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.summary())
    end)

    assert {:ok, summary} = Client.summary(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert summary.model_description == "Taycan GTS"
    assert summary.nickname == nil
  end

  test "summary with nickname", %{session: session, bypass: bypass} do
    vin = random_vin()
    nickname = random_nickname()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.summary(nickname))
    end)

    assert {:ok, summary} = Client.summary(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert summary.model_description == "Taycan GTS"
    assert summary.nickname == nickname
  end

  test "stored_overview", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
      fn conn ->
        resp_json(conn, ServerResponses.overview(vin, true))
      end
    )

    assert {:ok, overview} = Client.stored_overview(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert overview.vin == vin
    assert overview.car_model == "J1"
    assert overview.engine_type == "BEV"
    assert overview.mileage == distance_km_to_km(9001.0)
    assert overview.battery_level == battery_level(80)
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
    assert overview.windows.sunroof.percent == nil
    assert overview.windows.sunroof.status == nil

    assert overview.tires.front_left == tire_pressure(2.4, 2.7, 0.3, :divergent)
    assert overview.tires.front_right == tire_pressure(2.4, 2.7, 0.3, :divergent)
    assert overview.tires.back_left == tire_pressure(2.3, 2.5, 0.2, :divergent)
    assert overview.tires.back_right == tire_pressure(2.3, 2.4, 0.1, :divergent)

    assert overview.open_status == :closed
    assert overview.parking_brake == :inactive
    assert overview.parking_brake_status == nil
    assert overview.parking_light == :off
    assert overview.parking_light_status == nil
    assert overview.parking_time == ~U[2024-01-17 21:48:10Z]

    assert %{electrical: elec, conventional: conv} = overview.remaining_ranges
    assert elec.distance == distance_km_to_km(247.0)
    assert elec.engine_type == :electric
    assert elec.primary? == true
    assert conv.distance == nil
    assert conv.engine_type == nil
    assert conv.primary? == false

    assert %{"inspection" => inspect, "oilService" => nil} = overview.service_intervals
    assert inspect.distance == distance_km_to_km(-21300.0)
    assert inspect.time == time(-113, :day)

    assert overview.oil_level == nil
    assert overview.fuel_level == nil
  end

  test "stored_overview with null tire data", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
      fn conn ->
        resp_json(conn, ServerResponses.overview(vin, false))
      end
    )

    assert {:ok, overview} = Client.stored_overview(session, vin, config(bypass))
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

  test "current_overview", %{session: session, bypass: bypass} do
    vin = random_vin()
    req_id = random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)

    Bypass.expect_once(
      bypass,
      "POST",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/current/request",
      fn conn ->
        resp_json(conn, ServerResponses.request_id(req_id))
      end
    )

    Bypass.expect(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/current/request/#{req_id}/status",
      fn conn ->
        resp_json(
          conn,
          case StatusCounter.tick(counter) do
            :halt -> ServerResponses.status_success()
            :cont -> ServerResponses.status_in_progress()
          end
        )
      end
    )

    Bypass.expect_once(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/current/request/#{req_id}",
      fn conn ->
        resp_json(conn, ServerResponses.overview(vin))
      end
    )

    assert {:ok, overview} = Client.current_overview(session, vin, config(bypass))
    assert MockSession.count(session) == status_requests + 2
    assert StatusCounter.get(counter) == 0

    assert overview.vin == vin
    assert overview.car_model == "J1"
    assert overview.engine_type == "BEV"
    assert overview.mileage == distance_km_to_km(9001.0)
    assert overview.battery_level == battery_level(80)
  end

  test "capabilities", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vcs/capabilities/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.capabilities())
    end)

    assert {:ok, caps} = Client.capabilities(session, vin, config(bypass))
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

  test "maintenance", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/predictive-maintenance/information/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.maintenance())
    end)

    assert {:ok, maint} = Client.maintenance(session, vin, config(bypass))
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

  test "emobility", %{session: session, bypass: bypass} do
    vin = random_vin()
    model = random_model()
    tz = random_timezone()
    config = config(bypass, timezone: tz)

    Bypass.expect_once(bypass, "GET", "/e-mobility/de/de_DE/#{model}/#{vin}", fn conn ->
      assert %{"timezone" => ^tz} = conn.query_params
      resp_json(conn, ServerResponses.emobility())
    end)

    assert {:ok, emobility} = Client.emobility(session, vin, model, config)
    assert MockSession.count(session) == 1

    assert charging = emobility.charging
    assert charging.mode == :off
    assert charging.plug == :connected
    assert charging.plug_lock == :locked
    assert charging.state == :completed
    assert charging.reason == :schedule
    assert charging.external_power == :station_connected
    assert charging.led_color == :green
    assert charging.led_state == :solid
    assert charging.percent == 80
    assert charging.minutes_to_full == 0
    assert charging.remaining_electric_range == distance_km_to_km(248)
    assert charging.remaining_conventional_range == nil
    assert charging.target_time == ~N[2024-01-17 19:55:00]
    assert charging.target_opl_enforced == nil
    assert charging.rate == charge_rate(0, 0)
    assert charging.kilowatts == 0
    assert charging.dc_mode? == false

    assert emobility.direct_charge.disabled? == false
    assert emobility.direct_charge.active? == false

    assert climate = emobility.direct_climate
    assert climate.state == :off
    assert climate.remaining_minutes == nil
    assert climate.target_temperature == temperature(2930, 20)
    assert climate.without_hv_power == false
    assert climate.heater_source == :electric

    assert [first, _, _, _, last] = emobility.timers

    assert first.id == 1
    assert first.active? == true
    assert first.depart_time == ~N[2024-01-20 18:41:00]
    assert first.frequency == :single
    assert first.climate? == true
    assert first.charge? == false
    assert first.weekdays == nil
    assert first.target_charge == 85

    assert last.id == 5
    assert last.active? == true
    assert last.depart_time == ~N[2024-01-17 07:00:00]
    assert last.frequency == :repeating
    assert last.climate? == false
    assert last.charge? == true
    assert last.weekdays == [1, 2, 3, 4, 5, 6, 7]
    assert last.target_charge == 80

    assert emobility.current_charging_profile_id == 5
    assert Enum.count(emobility.charging_profiles) == 2
    assert %{4 => profile4, 5 => profile5} = emobility.charging_profiles

    assert profile4.id == 4
    assert profile4.name == "Allgemein"
    assert profile4.active == true
    assert profile4.charging.minimum == 30
    assert profile4.charging.target == 100
    assert profile4.charging.mode == :smart
    assert profile4.charging.preferred_time_start == ~T[19:00:00]
    assert profile4.charging.preferred_time_end == ~T[07:00:00]
    assert profile4.position == nil

    assert profile5.id == 5
    assert profile5.name == "Home"
    assert profile5.active == true
    assert profile5.charging.minimum == 30
    assert profile5.charging.target == 100
    assert profile5.charging.mode == :preferred_time
    assert profile5.charging.preferred_time_start == ~T[19:00:00]
    assert profile5.charging.preferred_time_end == ~T[07:00:00]
    assert profile5.position.latitude == 45.444444
    assert profile5.position.longitude == -75.693889
    assert profile5.position.radius == 250
  end

  test "position", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/car-finder/#{vin}/position", fn conn ->
      resp_json(conn, ServerResponses.position())
    end)

    assert {:ok, position} = Client.position(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert position.coordinates.latitude == 45.444444
    assert position.coordinates.longitude == -75.693889
    assert position.coordinates.reference_system == :wgs84
    assert position.heading == 90
  end

  test "trips_short_term", %{session: session, bypass: bypass} do
    vin = random_vin()
    trip_count = Enum.random(5..50)

    Bypass.expect_once(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/trips/#{vin}/SHORT_TERM",
      fn conn ->
        resp_json(conn, ServerResponses.trips_short_term(trip_count))
      end
    )

    assert {:ok, trips} = Client.trips_short_term(session, vin, config(bypass))
    assert MockSession.count(session) == 1
    assert Enum.count(trips) == trip_count

    assert %{"endMileage" => %{"value" => 9001}} = trips |> Enum.at(0)
  end

  test "trips_long_term", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/trips/#{vin}/LONG_TERM",
      fn conn ->
        resp_json(conn, ServerResponses.trips_long_term())
      end
    )

    assert {:ok, trips} = Client.trips_long_term(session, vin, config(bypass))
    assert MockSession.count(session) == 1
    assert Enum.count(trips) == 2
    assert %{"endMileage" => %{"value" => 9001}} = trips |> Enum.at(0)
    assert %{"endMileage" => %{"value" => 7242}} = trips |> Enum.at(1)
  end

  test "put_timer", %{session: session, bypass: bypass} do
    vin = random_vin()
    model = random_model()

    req_id = random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)

    timer =
      %{
        "active" => true,
        "chargeOption" => false,
        "climatisationTimer" => false,
        "climatised" => true,
        "departureDateTime" => "2024-01-18T15:52:00.000Z",
        "e3_CLIMATISATION_TIMER_ID" => "4",
        "frequency" => "SINGLE",
        "preferredChargingEndTime" => nil,
        "preferredChargingStartTime" => nil,
        "preferredChargingTimeEnabled" => false,
        "targetChargeLevel" => 85,
        "timerID" => "3",
        "weekDays" => nil
      }

    Bypass.expect_once(
      bypass,
      "PUT",
      "/e-mobility/de/de_DE/#{model}/#{vin}/timer",
      fn conn ->
        {:ok, body, conn} = conn |> Plug.Conn.read_body()
        assert body |> Jason.decode!() == timer
        resp_json(conn, ServerResponses.action_in_progress(req_id))
      end
    )

    Bypass.expect(
      bypass,
      "GET",
      "/e-mobility/de/de_DE/#{model}/#{vin}/action-status/#{req_id}",
      fn conn ->
        assert %{"hasDX1" => "false"} = conn.query_params

        resp_json(
          conn,
          case StatusCounter.tick(counter) do
            :halt -> ServerResponses.action_success(req_id)
            :cont -> ServerResponses.action_in_progress(req_id)
          end
        )
      end
    )

    assert {:ok, "SUCCESS"} = Client.put_timer(session, vin, model, timer, config(bypass))
    assert MockSession.count(session) == status_requests + 1
  end

  test "delete_timer", %{session: session, bypass: bypass} do
    vin = random_vin()
    model = random_model()
    timer_id = Enum.random(1..5)

    req_id = random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)

    Bypass.expect_once(
      bypass,
      "DELETE",
      "/e-mobility/de/de_DE/#{model}/#{vin}/timer/#{timer_id}",
      fn conn ->
        resp_json(conn, ServerResponses.action_in_progress(req_id))
      end
    )

    Bypass.expect(
      bypass,
      "GET",
      "/e-mobility/de/de_DE/#{model}/#{vin}/action-status/#{req_id}",
      fn conn ->
        assert %{"hasDX1" => "false"} = conn.query_params

        resp_json(
          conn,
          case StatusCounter.tick(counter) do
            :halt -> ServerResponses.action_success(req_id)
            :cont -> ServerResponses.action_in_progress(req_id)
          end
        )
      end
    )

    assert {:ok, "SUCCESS"} = Client.delete_timer(session, vin, model, timer_id, config(bypass))
    assert MockSession.count(session) == status_requests + 1
  end

  test "put_profile", %{session: session, bypass: bypass} do
    vin = random_vin()
    model = random_model()

    req_id = random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)

    profile =
      %{
        "chargingOptions" => %{
          "minimumChargeLevel" => 30,
          "preferredChargingEnabled" => true,
          "preferredChargingTimeEnd" => "07:00",
          "preferredChargingTimeStart" => "19:00",
          "smartChargingEnabled" => false,
          "targetChargeLevel" => 100
        },
        "position" => %{
          "latitude" => 45.444444,
          "longitude" => -75.693889,
          "radius" => 250,
          "radiusUnit" => "noUnit"
        },
        "profileActive" => true,
        "profileId" => 5,
        "profileName" => "Home",
        "profileOptions" => %{
          "autoPlugUnlockEnabled" => false,
          "energyCostOptimisationEnabled" => false,
          "energyMixOptimisationEnabled" => false,
          "powerLimitationEnabled" => false,
          "timeBasedEnabled" => false,
          "usePrivateCurrentEnabled" => true
        },
        "timerActionList" => %{"timerAction" => [1, 2, 3, 4, 5]}
      }

    Bypass.expect_once(
      bypass,
      "PUT",
      "/e-mobility/de/de_DE/#{model}/#{vin}/profile",
      fn conn ->
        {:ok, body, conn} = conn |> Plug.Conn.read_body()
        assert body |> Jason.decode!() == profile
        resp_json(conn, ServerResponses.action_in_progress(req_id))
      end
    )

    Bypass.expect(
      bypass,
      "GET",
      "/e-mobility/de/de_DE/#{model}/#{vin}/action-status/#{req_id}",
      fn conn ->
        assert %{"hasDX1" => "false"} = conn.query_params

        resp_json(
          conn,
          case StatusCounter.tick(counter) do
            :halt -> ServerResponses.action_success(req_id)
            :cont -> ServerResponses.action_in_progress(req_id)
          end
        )
      end
    )

    assert {:ok, "SUCCESS"} = Client.put_profile(session, vin, model, profile, config(bypass))
    assert MockSession.count(session) == status_requests + 1
  end

  test "climate_set", %{session: session, bypass: bypass} do
    vin = random_vin()
    req_id = random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)
    enable = [true, false] |> Enum.random()

    Bypass.expect_once(
      bypass,
      "POST",
      "/e-mobility/de/de_DE/#{vin}/toggle-direct-climatisation/#{enable}",
      fn conn ->
        resp_json(conn, ServerResponses.request_id(req_id))
      end
    )

    Bypass.expect(
      bypass,
      "GET",
      "/e-mobility/de/de_DE/#{vin}/toggle-direct-climatisation/status/#{req_id}",
      fn conn ->
        resp_json(
          conn,
          case StatusCounter.tick(counter) do
            :halt -> ServerResponses.status_success()
            :cont -> ServerResponses.status_in_progress()
          end
        )
      end
    )

    assert {:ok, "SUCCESS"} = Client.climate_set(session, vin, enable, config(bypass))
    assert MockSession.count(session) == status_requests + 1
  end

  defp config(bypass, params \\ []) do
    %Config{
      api_url: "http://localhost:#{bypass.port}",
      status_delay: 1
    }
    |> struct!(params)
  end

  defp resp_json(conn, body) do
    conn
    |> Conn.put_resp_header("content-type", "application/json")
    |> Conn.resp(200, body)
  end

  @vin_chars [?A..?Z, ?0..?9]
             |> Enum.flat_map(& &1)
             |> Enum.reject(&(&1 in [?O, ?I, ?Q]))
  @vin_length 17

  defp random_vin do
    1..@vin_length
    |> Enum.map(fn _ -> Enum.random(@vin_chars) end)
    |> String.Chars.to_string()
  end

  @nickname_chars [?A..?Z, ?a..?z] |> Enum.flat_map(& &1)
  @nickname_length 1..24

  defp random_nickname do
    1..Enum.random(@nickname_length)
    |> Enum.map(fn _ -> Enum.random(@nickname_chars) end)
    |> String.Chars.to_string()
  end

  # Taken from https://en.wikipedia.org/wiki/List_of_Volkswagen_Group_platforms
  # These are just guesses.  The only one I know for sure is used in the API is "J1".
  @models ~w{MLB MLP PL71 PL72 MMB J1 PPE}
  defp random_model, do: @models |> Enum.random()

  defp random_request_id do
    Enum.random(1_000_000_000..9_999_999_999)
    |> Integer.to_string()
  end

  # Arbitrary sampling.
  @timezones [
    "Etc/UTC",
    "America/Toronto",
    "America/Vancouver",
    "America/Regina",
    "Europe/Berlin",
    "Europe/London",
    "Asia/Tokyo",
    "Australia/Sydney"
  ]

  defp random_timezone, do: @timezones |> Enum.random()

  defp distance_km_to_km(value) do
    %Struct.Distance{
      value: value,
      unit: :km,
      original_value: value,
      original_unit: :km,
      km: value
    }
  end

  defp time(value, unit) when unit in [:day] do
    %Struct.Time{
      value: value,
      unit: unit
    }
  end

  defp battery_level(value) do
    %Struct.BatteryLevel{
      value: value,
      unit: :percent
    }
  end

  defp lock(open, locked) do
    %Struct.Status.LockStatus{
      open:
        case open do
          :open -> true
          :closed -> false
        end,
      locked:
        case locked do
          :locked -> true
          :unlocked -> false
        end
    }
  end

  defp tire_pressure(current, optimal, diff, status) do
    %Struct.Overview.TirePressure{
      current: %Struct.Pressure{value: current, unit: :bar},
      optimal: %Struct.Pressure{value: optimal, unit: :bar},
      difference: %Struct.Pressure{value: diff, unit: :bar},
      status: status
    }
  end

  defp charge_rate(km_per_minute, km_per_hour) do
    %Struct.Emobility.ChargeRate{
      value: km_per_minute,
      unit: :km_per_minute,
      km_per_hour: km_per_hour
    }
  end

  defp temperature(dk, celsius) do
    %Struct.Emobility.Temperature{
      decikelvin: dk,
      celsius: celsius
    }
  end
end
