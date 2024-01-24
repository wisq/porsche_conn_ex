defmodule PorscheConnEx.Test.Bypass do
  def resp_json(conn, body) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.resp(200, body)
  end
end
