defmodule PorscheConnEx.Struct.Status.LockStatusTest do
  use ExUnit.Case, async: true

  alias PorscheConnEx.Struct.Status.LockStatus

  @module inspect(LockStatus)

  test "open and unlocked" do
    assert %LockStatus{open?: true, locked?: false} |> inspect() ==
             "##{@module}<open,unlocked>"
  end

  test "closed and unlocked" do
    assert %LockStatus{open?: false, locked?: false} |> inspect() ==
             "##{@module}<closed,unlocked>"
  end

  test "closed and locked" do
    assert %LockStatus{open?: false, locked?: true} |> inspect() ==
             "##{@module}<closed,locked>"
  end
end
