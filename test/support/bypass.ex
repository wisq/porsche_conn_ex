defmodule PorscheConnEx.Test.Bypass do
  alias PorscheConnEx.Test.{StatusCounter, ServerResponses}

  def resp_json(conn, body) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.resp(200, body)
  end

  def expect_action_in_progress(bypass, base_url, req_id, count) do
    {:ok, counter} = StatusCounter.start_link(count: count)

    Bypass.expect(
      bypass,
      "GET",
      "#{base_url}/action-status/#{req_id}",
      fn conn ->
        %{"hasDX1" => "false"} = conn.query_params

        resp_json(
          conn,
          case StatusCounter.tick(counter) do
            :halt -> ServerResponses.action_success(req_id)
            :cont -> ServerResponses.action_in_progress(req_id)
          end
        )
      end
    )
  end

  def expect_status_in_progress(bypass, base_url, req_id, count) do
    {:ok, counter} = StatusCounter.start_link(count: count)

    Bypass.expect(
      bypass,
      "GET",
      "#{base_url}/#{req_id}/status",
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
  end
end
