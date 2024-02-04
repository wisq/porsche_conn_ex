defmodule PorscheConnEx.Struct.Unit.TimeTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Test.UnitFactory

  @module inspect(PorscheConnEx.Struct.Unit.Time)

  test "inspect plural" do
    assert UnitFactory.time(123, :day) |> inspect() == "##{@module}<123 days>"
    assert UnitFactory.time(0, :day) |> inspect() == "##{@module}<0 days>"
  end

  test "inspect singular" do
    assert UnitFactory.time(1, :day) |> inspect() == "##{@module}<1 day>"
  end

  test "inspect negative" do
    assert UnitFactory.time(-1, :day) |> inspect() == "##{@module}<-1 days>"
    assert UnitFactory.time(-123, :day) |> inspect() == "##{@module}<-123 days>"
  end
end
