defmodule PorscheConnEx.Struct.Overview.TirePressure do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  enum Status do
    value(nil, key: "UNKNOWN")
    # Only known value I've seen so far.
    value(:divergent, key: "DIVERGENT")
  end

  param do
    field(:current, Struct.Unit.Pressure, key: "currentPressure")
    field(:optimal, Struct.Unit.Pressure, key: "optimalPressure")
    field(:difference, Struct.Unit.Pressure, key: "differencePressure")
    field(:status, Status, key: "tirePressureDifferenceStatus", required: true)
  end
end
