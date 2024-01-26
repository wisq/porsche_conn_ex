defmodule PorscheConnEx.ClientDeleteTimerTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  describe "delete_timer/4" do
    test "issues and completes pending request", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      model = Data.random_model()
      req_id = Data.random_request_id()
      wait_count = Enum.random(5..10)
      timer_id = Enum.random(1..5)

      base_url = "/e-mobility/de/de_DE/#{model}/#{vin}"

      Bypass.expect_once(bypass, "DELETE", "#{base_url}/timer/#{timer_id}", fn conn ->
        resp_json(conn, ServerResponses.action_in_progress(req_id))
      end)

      # Issue initial request:
      assert {:ok, pending} = Client.delete_timer(session, vin, model, timer_id)
      assert MockSession.count(session) == 1

      # Wait for final status:
      expect_action_in_progress(bypass, base_url, req_id, wait_count)
      assert {:ok, :success} = Client.wait(session, pending, delay: 1)
      assert MockSession.count(session) == 2
    end
  end
end
