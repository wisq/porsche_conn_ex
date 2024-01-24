defmodule PorscheConnEx.ClientSummaryTest do
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

  test "summary", %{session: session, bypass: bypass} do
    vin = Data.random_vin()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.summary())
    end)

    assert {:ok, summary} = Client.summary(session, vin, Data.config(bypass))
    assert MockSession.count(session) == 1

    assert summary.model_description == "Taycan GTS"
    assert summary.nickname == nil
  end

  test "summary with nickname", %{session: session, bypass: bypass} do
    vin = Data.random_vin()
    nickname = Data.random_nickname()

    Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
      resp_json(conn, ServerResponses.summary(nickname))
    end)

    assert {:ok, summary} = Client.summary(session, vin, Data.config(bypass))
    assert MockSession.count(session) == 1

    assert summary.model_description == "Taycan GTS"
    assert summary.nickname == nickname
  end
end
