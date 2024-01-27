defmodule PorscheConnEx.Struct.Unit.BatteryLevel do
  use PorscheConnEx.Struct

  enum Unit do
    value(:percent, key: "PERCENT")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :integer, required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.BatteryLevel do
  alias PorscheConnEx.Struct.Unit.BatteryLevel

  def inspect(%BatteryLevel{unit: :percent, value: value}, _opts) do
    "#PCX:BatteryLevel<#{value}%>"
  end
end
