defmodule PorscheConnEx.ClientClimateSetTest do
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

  describe "climate_set/3" do
    test "issues request and waits for success", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      req_id = Data.random_request_id()
      wait_count = Enum.random(5..10)
      enable = [true, false] |> Enum.random()

      base_url = "/e-mobility/de/de_DE/#{vin}/toggle-direct-climatisation"

      Bypass.expect_once(
        bypass,
        "POST",
        "#{base_url}/#{enable}",
        fn conn ->
          # Note that this is one of the few actions to use HTTP status 202.
          resp_json(conn, 202, ServerResponses.request_id(req_id))
        end
      )

      expect_status_in_progress_reversed(bypass, base_url, req_id, wait_count)

      assert {:ok, "SUCCESS"} = Client.climate_set(session, vin, enable, Data.config(bypass))
      assert MockSession.count(session) == wait_count + 1
    end

    test "returns error if operation fails", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      req_id = Data.random_request_id()
      wait_count = Enum.random(5..10)
      enable = [true, false] |> Enum.random()

      base_url = "/e-mobility/de/de_DE/#{vin}/toggle-direct-climatisation"

      Bypass.expect_once(
        bypass,
        "POST",
        "#{base_url}/#{enable}",
        fn conn ->
          resp_json(conn, 202, ServerResponses.request_id(req_id))
        end
      )

      expect_status_in_progress_reversed(
        bypass,
        base_url,
        req_id,
        wait_count,
        ServerResponses.status_failed()
      )

      assert {:error, "FAIL"} = Client.climate_set(session, vin, enable, Data.config(bypass))
    end

    test "returns error if operation never succeeds", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      req_id = Data.random_request_id()
      wait_count = 999
      enable = [true, false] |> Enum.random()

      base_url = "/e-mobility/de/de_DE/#{vin}/toggle-direct-climatisation"

      Bypass.expect_once(
        bypass,
        "POST",
        "#{base_url}/#{enable}",
        fn conn ->
          resp_json(conn, 202, ServerResponses.request_id(req_id))
        end
      )

      expect_status_in_progress_reversed(
        bypass,
        base_url,
        req_id,
        wait_count,
        ServerResponses.status_failed()
      )

      config = Data.config(bypass, max_status_checks: Enum.random(10..20))
      assert {:error, "IN_PROGRESS"} = Client.climate_set(session, vin, enable, config)
      assert MockSession.count(session) == config.max_status_checks + 1
    end
  end
end
