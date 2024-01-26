defmodule PorscheConnEx.ClientSummaryTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  describe "Client.summary/2" do
    test "without a nickname, gets a vehicle summary", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
        resp_json(conn, ServerResponses.summary())
      end)

      assert {:ok, summary} = Client.summary(session, vin, Data.config(bypass))
      assert MockSession.count(session) == 1

      assert summary.model_description == "Taycan GTS"
      assert summary.nickname == nil
    end

    test "with a nickname, gets a vehicle summary", %{session: session, bypass: bypass} do
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

    test "handles timeout", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.stub(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.summary(session, vin, Data.config(bypass))

      timeout_cleanup(bypass)
    end

    test "handles unknown VIN", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", "/service-vehicle/vehicle-summary/#{vin}", fn conn ->
        resp_json(conn, 502, ServerResponses.unknown_502_error())
      end)

      assert {:error, :unknown} = Client.summary(session, vin, Data.config(bypass))
    end
  end
end
