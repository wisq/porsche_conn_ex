defmodule PorscheConnEx.Struct.Time do
  use PorscheConnEx.Struct

  enum Unit do
    # Only value I've seen so far.
    value(:day, key: "DAYS")
  end

  alias __MODULE__.Unit

  param do
    field(:unit, Unit, required: true)
    field(:value, :integer, required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Time do
  def inspect(time, _opts) do
    "#PCX:Time<#{time.value} #{time.unit}s>"
  end
end