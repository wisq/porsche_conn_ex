defmodule PorscheConnEx.Struct.Unit.Consumption.EnergyTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.Consumption.Energy)

  test "inspect with metric units" do
    assert UnitFactory.energy_consumption_km(12.3) |> inspect() ==
             "##{@module}<12.3 kWh/100km>"
  end

  test "inspect with imperial units" do
    assert UnitFactory.energy_consumption_mi(12.3, 19.1) |> inspect() ==
             "##{@module}<12.3 mi/kWh / 19.1 kWh/100km>"
  end
end
