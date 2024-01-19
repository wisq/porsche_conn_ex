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

    assert %Struct.Vehicle{
             vin: ^vin,
             model_year: 2022,
             model_description: "Taycan GTS",
             attributes: []
           } = vehicle
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
    assert vehicle.model_year == 2022
    assert vehicle.model_description == "Taycan GTS"
    assert [%{name: "licenseplate", value: ^nickname}] = vehicle.attributes
  end

  test "status", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/vehicle-data/de/de_DE/status/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.status(vin))
    end)

    assert {:ok, %Struct.Status{} = status} = Client.status(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert status.vin == vin
    assert status.mileage.value == 9001
    assert status.battery_level.value == 80
    assert status.remaining_ranges.electrical.distance.value == 247
    assert status.overall_lock_status.locked

    assert %{"inspection" => inspection} = status.service_intervals
    assert inspection.time.value == -113
  end

  test "summary", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.summary())
    end)

    assert {:ok, summary} = Client.summary(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert %Struct.Summary{model_description: "Taycan GTS", nickname: nil} = summary
  end

  test "summary with nickname", %{session: session, bypass: bypass} do
    vin = random_vin()
    nickname = random_nickname()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.summary(nickname))
    end)

    assert {:ok, summary} = Client.summary(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert %Struct.Summary{model_description: "Taycan GTS", nickname: ^nickname} = summary
  end

  test "stored_overview/3", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(
      bypass,
      "GET",
      "/service-vehicle/de/de_DE/vehicle-data/#{vin}/stored",
      fn conn ->
        resp_json(conn, ServerResponses.overview(vin))
      end
    )

    assert {:ok, %Struct.Overview{} = overview} =
             Client.stored_overview(session, vin, config(bypass))

    assert MockSession.count(session) == 1

    assert overview.vin == vin
    assert overview.mileage.value == 9001
    assert overview.battery_level.value == 80

    assert overview.remaining_ranges.electrical.distance.value == 247
    assert overview.remaining_ranges.electrical.is_primary
    refute overview.remaining_ranges.conventional.is_primary

    assert overview.doors.front_left.locked
    refute overview.doors.front_left.open
  end

  test "current_overview/3", %{session: session, bypass: bypass} do
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

    assert %{
             "vin" => ^vin,
             "mileage" => %{"value" => 9001},
             "batteryLevel" => %{"value" => 80},
             "remainingRanges" => %{"electricalRange" => %{"distance" => %{"value" => 247}}}
           } = overview
  end

  test "capabilities", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vcs/capabilities/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.capabilities())
    end)

    assert {:ok, caps} = Client.capabilities(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert %{
             "carModel" => "J1",
             "engineType" => "BEV",
             "heatingCapabilities" => %{
               "frontSeatHeatingAvailable" => true,
               "rearSeatHeatingAvailable" => true
             }
           } = caps
  end

  test "maintenance", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/predictive-maintenance/information/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.maintenance())
    end)

    assert {:ok, maint} = Client.maintenance(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert %{"data" => schedule} = maint
    assert Enum.count(schedule) == 13

    assert %{
             "id" => "0003",
             "criticality" => 1,
             "description" => %{"shortName" => "Inspektion"}
           } = schedule |> Enum.at(0)
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

    assert %{
             "batteryChargeStatus" => %{
               "stateOfChargeInPercentage" => 80,
               "remainingERange" => %{"value" => 248}
             },
             "directClimatisation" => %{"climatisationState" => "OFF"},
             "timers" => timers,
             "chargingProfiles" => %{"profiles" => profiles}
           } = emobility

    assert timers |> Enum.map(fn %{"timerID" => id} -> id end) == ~w{1 2 3 4 5}
    assert profiles |> Enum.map(fn %{"profileId" => id} -> id end) == [4, 5]
  end

  test "position", %{session: session, bypass: bypass} do
    vin = random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/car-finder/#{vin}/position", fn conn ->
      resp_json(conn, ServerResponses.position())
    end)

    assert {:ok, position} = Client.position(session, vin, config(bypass))
    assert MockSession.count(session) == 1

    assert %{
             "carCoordinate" => %{
               "latitude" => 45.444444,
               "longitude" => -75.693889
             },
             "heading" => 90
           } = position
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
end
