defmodule PorscheConnEx.ClientPutChargingProfileTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Test.{MockSession, ServerResponses, StatusCounter}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  setup do
    bypass = Bypass.open()
    {:ok, session} = MockSession.start_link()

    {:ok, bypass: bypass, session: session}
  end

  test "put_charging_profile", %{session: session, bypass: bypass} do
    vin = Data.random_vin()
    model = Data.random_model()

    req_id = Data.random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)

    profile = %Struct.Emobility.ChargingProfile{
      id: 3,
      name: "Test",
      active: true,
      charging: %Struct.Emobility.ChargingProfile.ChargingOptions{
        minimum_charge: 35,
        target_charge: 100,
        mode: :preferred_time,
        preferred_time_start: ~T[01:02:00],
        preferred_time_end: ~T[03:04:00]
      },
      position: %Struct.Emobility.ChargingProfile.Position{
        latitude: 45.444444,
        longitude: -75.693889,
        radius: 250
      }
    }

    me = self()

    Bypass.expect_once(
      bypass,
      "PUT",
      "/e-mobility/de/de_DE/#{model}/#{vin}/profile",
      fn conn ->
        {:ok, body, conn} = conn |> Plug.Conn.read_body()
        send(me, {:profile_json, body |> Jason.decode!()})
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

    assert {:ok, "SUCCESS"} =
             Client.put_charging_profile(session, vin, model, profile, Data.config(bypass))

    assert MockSession.count(session) == status_requests + 1

    assert_received {:profile_json, json}

    assert json == %{
             "profileId" => 3,
             "profileName" => "Test",
             "profileActive" => true,
             "chargingOptions" => %{
               "minimumChargeLevel" => 35,
               "targetChargeLevel" => 100,
               "mode" => "preferred_time",
               "preferredChargingTimeEnd" => "03:04",
               "preferredChargingTimeStart" => "01:02"
             },
             "position" => %{
               "latitude" => 45.444444,
               "longitude" => -75.693889,
               "radius" => 250
             }
           }
  end
end
