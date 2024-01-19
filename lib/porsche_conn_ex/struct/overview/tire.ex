defmodule PorscheConnEx.Struct.Overview.TirePressure do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type

  enum Status do
    # Only value I've seen so far.
    value(:divergent, key: "DIVERGENT")
  end

  alias __MODULE__.Status

  param do
    field(:current, Type.Struct.Pressure, key: "currentPressure")
    field(:optimal, Type.Struct.Pressure, key: "optimalPressure")
    field(:difference, Type.Struct.Pressure, key: "differencePressure")
    field(:status, Status, key: "tirePressureDifferenceStatus")
  end
end
