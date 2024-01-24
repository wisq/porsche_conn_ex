defmodule PorscheConnEx.ClientDeleteTimerTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses, StatusCounter}
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
    timer_id = Enum.random(1..5)

    req_id = Data.random_request_id()
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

    assert {:ok, "SUCCESS"} =
             Client.delete_timer(session, vin, model, timer_id, Data.config(bypass))

    assert MockSession.count(session) == status_requests + 1
  end
end
