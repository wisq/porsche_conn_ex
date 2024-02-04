defmodule PorscheConnEx.Struct.Unit.BatteryLevelTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.BatteryLevel)

  test "inspect" do
    assert UnitFactory.battery_level(0) |> inspect() == "##{@module}<0%>"
    assert UnitFactory.battery_level(12) |> inspect() == "##{@module}<12%>"
    assert UnitFactory.battery_level(34) |> inspect() == "##{@module}<34%>"
    assert UnitFactory.battery_level(100) |> inspect() == "##{@module}<100%>"
  end
end
