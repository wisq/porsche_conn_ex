defmodule PorscheConnEx.Struct.Unit.PressureTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.Pressure)

  test "inspect with metric units" do
    tire = UnitFactory.tire_pressure(2.3, 2.1, 0.2, :divergent)
    assert tire.current |> inspect() == "##{@module}<2.3 bar>"
    assert tire.optimal |> inspect() == "##{@module}<2.1 bar>"
    assert tire.difference |> inspect() == "##{@module}<0.2 bar>"
  end

  test "inspect with imperial units" do
    tire = UnitFactory.tire_pressure_psi(35.1, 30.2, 4.9, :divergent)
    assert tire.current |> inspect() == "##{@module}<35.1 psi / 2.4 bar>"
    assert tire.optimal |> inspect() == "##{@module}<30.2 psi / 2.1 bar>"
    assert tire.difference |> inspect() == "##{@module}<4.9 psi / 0.3 bar>"
  end
end
