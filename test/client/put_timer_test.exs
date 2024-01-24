defmodule PorscheConnEx.ClientPutTimerTest do
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

  test "put_timer", %{session: session, bypass: bypass} do
    vin = Data.random_vin()
    model = Data.random_model()

    req_id = Data.random_request_id()
    status_requests = Enum.random(5..10)
    {:ok, counter} = StatusCounter.start_link(count: status_requests)

    timer = %Struct.Emobility.Timer{
      id: 3,
      active?: true,
      depart_time: ~N[2024-01-18 15:52:00],
      frequency: :single,
      climate?: true,
      charge?: false
    }

    me = self()

    Bypass.expect_once(
      bypass,
      "PUT",
      "/e-mobility/de/de_DE/#{model}/#{vin}/timer",
      fn conn ->
        {:ok, body, conn} = conn |> Plug.Conn.read_body()
        send(me, {:timer_json, body |> Jason.decode!()})
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

    assert {:ok, "SUCCESS"} = Client.put_timer(session, vin, model, timer, Data.config(bypass))
    assert MockSession.count(session) == status_requests + 1

    assert_received {:timer_json, json}

    assert json == %{
             "timerID" => 3,
             "active" => true,
             "departureDateTime" => "2024-01-18T15:52:00.000Z",
             "frequency" => "SINGLE",
             "weekDays" => nil,
             "climatised" => true,
             "chargeOption" => false,
             "targetChargeLevel" => nil
           }
  end
end
