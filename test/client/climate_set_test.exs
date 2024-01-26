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
    test "issues and completes pending request", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      req_id = Data.random_request_id()
      wait_count = Enum.random(5..10)
      enable = [true, false] |> Enum.random()
      config = Data.config(bypass)

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

      # Issue initial request:
      assert {:ok, pending} = Client.climate_set(session, vin, enable, config)
      assert MockSession.count(session) == 1

      # Wait for final status:
      expect_status_in_progress_reversed(bypass, base_url, req_id, wait_count)
      assert {:ok, :success} = Client.wait(session, pending, [delay: 1], config)
      assert MockSession.count(session) == 1 + wait_count
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

      config = Data.config(bypass)
      assert {:ok, pending} = Client.climate_set(session, vin, enable, config)
      assert {:error, :failed} = Client.wait(session, pending, [delay: 1], config)
    end

    test "returns error if operation never succeeds", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      req_id = Data.random_request_id()
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
        999,
        ServerResponses.status_failed()
      )

      config = Data.config(bypass)
      wait_opts = [delay: 1, count: Enum.random(5..10)]
      assert {:ok, pending} = Client.climate_set(session, vin, enable, config)
      assert {:error, :in_progress} = Client.wait(session, pending, wait_opts, config)
    end
  end
end
