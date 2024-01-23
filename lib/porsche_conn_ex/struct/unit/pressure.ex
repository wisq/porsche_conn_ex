defmodule PorscheConnEx.Struct.Unit.Pressure do
  use PorscheConnEx.Struct

  enum Unit do
    value(:bar, key: "BAR")
  end

  alias __MODULE__.Unit

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Pressure do
  def inspect(pressure, _opts) do
    "#PCX:Pressure<#{pressure.value} #{pressure.unit}>"
  end
end
