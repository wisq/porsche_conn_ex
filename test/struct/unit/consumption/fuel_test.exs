defmodule PorscheConnEx.Struct.Unit.Consumption.FuelTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.Consumption.Fuel)

  test "inspect with metric units" do
    assert UnitFactory.fuel_consumption_km(12.3) |> inspect() == "##{@module}<12.3 L/100km>"
  end

  test "inspect with imperial units" do
    assert UnitFactory.fuel_consumption_mpg(12.3, 19.1) |> inspect() ==
             "##{@module}<12.3 mpg / 19.1 L/100km>"
  end
end
