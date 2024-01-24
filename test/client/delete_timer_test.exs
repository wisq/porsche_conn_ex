defmodule PorscheConnEx.ClientDeleteTimerTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  setup do
    bypass = Bypass.open()
    {:ok, session} = MockSession.start_link()

    {:ok, bypass: bypass, session: session}
  end

  test "delete_timer", %{session: session, bypass: bypass} do
    vin = Data.random_vin()
    model = Data.random_model()
    req_id = Data.random_request_id()
    wait_count = Enum.random(5..10)
    timer_id = Enum.random(1..5)

    base_url = "/e-mobility/de/de_DE/#{model}/#{vin}"

    Bypass.expect_once(bypass, "DELETE", "#{base_url}/timer/#{timer_id}", fn conn ->
      resp_json(conn, ServerResponses.action_in_progress(req_id))
    end)

    expect_action_in_progress(bypass, base_url, req_id, wait_count)

    assert {:ok, "SUCCESS"} =
             Client.delete_timer(session, vin, model, timer_id, Data.config(bypass))

    assert MockSession.count(session) == wait_count + 1
  end
end
