defmodule PorscheConnEx.Struct.Unit.Time do
  use PorscheConnEx.Struct

  enum Unit do
    # Only value I've seen so far.
    value(:day, key: "DAYS")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :integer, required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Time do
  def inspect(time, _opts) do
    "#PCX:Time<#{time.value} #{time.unit}s>"
  end
end
