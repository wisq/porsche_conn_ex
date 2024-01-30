defmodule PorscheConnEx.ClientPutTimerTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Struct.Emobility.Timer
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  describe "put_timer/4" do
    test "issues and completes pending request", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      model = Data.random_model()
      req_id = Data.random_request_id()
      wait_count = Enum.random(5..10)

      me = self()
      base_url = "/e-mobility/de/de_DE/#{model}/#{vin}"

      Bypass.expect_once(bypass, "PUT", "#{base_url}/timer", fn conn ->
        {:ok, body, conn} = conn |> Plug.Conn.read_body()
        send(me, {:timer_json, body |> Jason.decode!()})
        resp_json(conn, ServerResponses.action_in_progress(req_id))
      end)

      timer = %Timer{
        id: 3,
        enabled?: true,
        depart_time: ~N[2024-01-18 15:52:00],
        repeating?: false,
        climate?: true,
        charge?: false
      }

      # Issue initial request:
      assert {:ok, pending} = Client.put_timer(session, vin, model, timer)
      assert MockSession.count(session) == 1

      # Wait for final status:
      expect_action_in_progress(bypass, base_url, req_id, wait_count)
      assert {:ok, :success} = Client.wait(session, pending, delay: 1)
      assert MockSession.count(session) == 2

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

    test "uses POST instead of PUT if timer.id is nil", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      model = Data.random_model()
      req_id = Data.random_request_id()

      me = self()
      base_url = "/e-mobility/de/de_DE/#{model}/#{vin}"

      Bypass.expect_once(bypass, "POST", "#{base_url}/timer", fn conn ->
        {:ok, body, conn} = conn |> Plug.Conn.read_body()
        send(me, {:timer_json, body |> Jason.decode!()})
        resp_json(conn, ServerResponses.action_in_progress(req_id))
      end)

      timer = %Timer{
        id: nil,
        enabled?: true,
        depart_time: ~N[2024-01-20 23:11:00],
        repeating?: false,
        climate?: false,
        charge?: true
      }

      assert {:ok, _pending} = Client.put_timer(session, vin, model, timer)
      assert MockSession.count(session) == 1

      assert_received {:timer_json, json}

      assert json == %{
               "timerID" => nil,
               "active" => true,
               "departureDateTime" => "2024-01-20T23:11:00.000Z",
               "frequency" => "SINGLE",
               "weekDays" => nil,
               "climatised" => false,
               "chargeOption" => true,
               "targetChargeLevel" => nil
             }
    end
  end
end
