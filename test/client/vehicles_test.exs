defmodule PorscheConnEx.ClientVehiclesTest do
  use PorscheConnEx.Test.ClientCase

  alias PorscheConnEx.Client
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  @url "/core/api/v3/de/de_DE/vehicles"
  @url_en_ca "/core/api/v3/ca/en_CA/vehicles"

  describe "Client.vehicles/1" do
    test "without nickname, fetches list of vehicles", %{session: session, bypass: bypass} do
      vin = Data.random_vin()

      Bypass.expect_once(bypass, "GET", @url, fn conn ->
        resp_json(conn, ServerResponses.vehicles(vin))
      end)

      assert {:ok, [vehicle]} = Client.vehicles(session)
      assert MockSession.count(session) == 1

      assert vehicle.vin == vin
      assert vehicle.model_year == 2022
      assert vehicle.model_type == "Y1ADE1"
      assert vehicle.model_description == "Taycan GTS"
      assert vehicle.relationship == "OWNER"
      assert vehicle.login_method == "PORSCHE_ID"
      assert vehicle.exterior_color == "vulkangraumetallic/vulkangraumetallic"
      assert vehicle.exterior_color_hex == "#252625"
      assert vehicle.attributes == %{}

      assert vehicle.valid_from == ~U[2024-01-01 01:02:03.000Z]
      assert vehicle.pending_relationship_termination_at == nil

      assert vehicle.pcc? == true
      assert vehicle.spin_enabled? == true
      assert vehicle.ota_active? == true
    end

    test "with nickname, fetches list of vehicles", %{session: session, bypass: bypass} do
      vin = Data.random_vin()
      nickname = Data.random_nickname()

      Bypass.expect_once(bypass, "GET", @url, fn conn ->
        resp_json(conn, ServerResponses.vehicles(vin, nickname))
      end)

      assert {:ok, [%Struct.Vehicle{} = vehicle]} = Client.vehicles(session)
      assert MockSession.count(session) == 1

      assert vehicle.vin == vin
      assert vehicle.attributes == %{"licenseplate" => nickname}
    end

    test "handles timeout", %{session: session, bypass: bypass} do
      Bypass.stub(bypass, "GET", @url, fn _ ->
        Process.sleep(5000)
      end)

      assert {:error, :timeout} = Client.vehicles(session)

      timeout_cleanup(bypass)
    end

    test "handles unsupported locale", %{session: session, bypass: bypass} do
      Bypass.expect_once(bypass, "GET", @url_en_ca, fn conn ->
        resp_json(conn, 404, "")
      end)

      MockSession.update_config(session, language: "en", country: "CA")
      assert {:error, :not_found} = Client.vehicles(session)
    end

    test "handles unknown domain", %{session: session} do
      MockSession.update_config(session, api_url: "https://nonexistent.wisq.org/")
      assert {:error, :nxdomain} = Client.vehicles(session)
    end
  end
end
