defmodule PorscheConnEx.Struct.Unit.SpeedTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.Speed)

  test "inspect with metric units" do
    assert UnitFactory.speed_kmh(123.4) |> inspect() == "##{@module}<123.4 km/h>"
  end

  test "inspect with imperial units" do
    assert UnitFactory.speed_mph(123.4, 198.6) |> inspect() ==
             "##{@module}<123.4 mph / 198.6 km/h>"
  end
end
