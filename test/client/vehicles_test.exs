defmodule PorscheConnEx.ClientVehiclesTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Client
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Test.{MockSession, ServerResponses}
  alias PorscheConnEx.Test.DataFactory, as: Data
  import PorscheConnEx.Test.Bypass

  setup do
    bypass = Bypass.open()
    {:ok, session} = MockSession.start_link()

    {:ok, bypass: bypass, session: session}
  end

  test "vehicles", %{session: session, bypass: bypass} do
    vin = Data.random_vin()

    Bypass.expect_once(bypass, "GET", "/core/api/v3/de/de_DE/vehicles", fn conn ->
      resp_json(conn, ServerResponses.vehicles(vin))
    end)

    assert {:ok, [vehicle]} = Client.vehicles(session, Data.config(bypass))
    assert MockSession.count(session) == 1

    assert vehicle.vin == vin
    assert vehicle.model_year == 2022
    assert vehicle.model_type == "Y1ADE1"
    assert vehicle.model_description == "Taycan GTS"
    assert vehicle.relationship == "OWNER"
    assert vehicle.login_method == "PORSCHE_ID"
    assert vehicle.exterior_color == "vulkangraumetallic/vulkangraumetallic"
    assert vehicle.exterior_color_hex == "#252625"
    assert vehicle.attributes == []

    assert vehicle.valid_from == ~U[2024-01-01 01:02:03.000Z]
    assert vehicle.pending_relationship_termination_at == nil

    assert vehicle.pcc? == true
    assert vehicle.spin_enabled? == true
    assert vehicle.ota_active? == true
  end

  test "vehicles with nickname", %{session: session, bypass: bypass} do
    vin = Data.random_vin()
    nickname = Data.random_nickname()

    Bypass.expect_once(bypass, "GET", "/core/api/v3/de/de_DE/vehicles", fn conn ->
      resp_json(conn, ServerResponses.vehicles(vin, nickname))
    end)

    assert {:ok, [%Struct.Vehicle{} = vehicle]} = Client.vehicles(session, Data.config(bypass))
    assert MockSession.count(session) == 1

    assert vehicle.vin == vin
    assert [%{name: "licenseplate", value: ^nickname}] = vehicle.attributes
  end
end
