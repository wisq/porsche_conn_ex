defmodule PorscheConnEx.Struct.Overview.TirePressure do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  enum Status do
    # Only value I've seen so far.
    value(:divergent, key: "DIVERGENT")
  end

  alias __MODULE__.Status

  param do
    field(:current, Struct.Pressure, key: "currentPressure")
    field(:optimal, Struct.Pressure, key: "optimalPressure")
    field(:difference, Struct.Pressure, key: "differencePressure")
    field(:status, Status, key: "tirePressureDifferenceStatus")
  end
end
