defmodule PorscheConnEx.Struct.Unit.ChargeRateTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.ChargeRate)

  test "inspect with metric units" do
    assert UnitFactory.charge_rate_km(1.2, 72.0) |> inspect() ==
             "##{@module}<1.2 km/min / 72.0 km/h>"
  end

  test "inspect with imperial units" do
    assert UnitFactory.charge_rate_miles(1.2, 115.873) |> inspect() ==
             "##{@module}<1.2 mi/min / 115.873 km/h>"
  end
end
