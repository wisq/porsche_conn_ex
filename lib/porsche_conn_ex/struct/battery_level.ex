defmodule PorscheConnEx.Struct.BatteryLevel do
  use PorscheConnEx.Struct

  enum Unit do
    value(:percent, key: "PERCENT")
  end

  alias __MODULE__.Unit

  param do
    field(:unit, Unit, required: true)
    field(:value, :integer, required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.BatteryLevel do
  alias PorscheConnEx.Struct.BatteryLevel

  def inspect(%BatteryLevel{unit: :percent, value: value}, _opts) do
    "#PCX:BatteryLevel<#{value}%>"
  end
end
