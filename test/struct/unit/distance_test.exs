defmodule PorscheConnEx.Struct.Unit.DistanceTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.Distance)

  test "inspect with metric units" do
    assert UnitFactory.distance_km(234.5) |> inspect() == "##{@module}<234.5 km>"
  end

  test "inspect with imperial units" do
    assert UnitFactory.distance_miles(345.6, 556.2) |> inspect() ==
             "##{@module}<345.6 mi / 556.2 km>"
  end
end
