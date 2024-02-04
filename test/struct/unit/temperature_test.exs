defmodule PorscheConnEx.Struct.Unit.TemperatureTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.Temperature)

  test "inspect with metric units" do
    assert UnitFactory.temperature(1234, -14.9) |> inspect() ==
             "##{@module}<-14.9°C / 1234 dK>"
  end

  test "inspect with imperial units" do
    assert UnitFactory.temperature(3210, 48.0) |> inspect() ==
             "##{@module}<48.0°C / 3210 dK>"
  end
end
