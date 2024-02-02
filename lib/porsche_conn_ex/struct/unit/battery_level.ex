defmodule PorscheConnEx.Struct.Unit.BatteryLevel do
  @moduledoc """
  Structure representing battery charge level.

  ## Fields

  - `unit` (atom) — only known value is `:percent`
  - `value` (integer) — percentage of full

  It's a bit of a silly unit, since it could just be replaced by an integer
  percentage.  In fact, "emobility" calls do exactly that; this structure is
  only used in "status" and "overview" calls.

  I assume it's just used for app/web UI presentation purposes, but maybe
  there's some other nuance I'm not aware of.
  """

  use PorscheConnEx.Struct

  enum Unit do
    value(:percent, key: "PERCENT")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :integer, required: true)
  end

  @type unit :: :percent
  @type t :: %__MODULE__{
          unit: unit,
          value: 0..100
        }
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.BatteryLevel do
  alias PorscheConnEx.Struct.Unit.BatteryLevel

  def inspect(%BatteryLevel{unit: :percent, value: value}, _opts) do
    "#PCX:BatteryLevel<#{value}%>"
  end
end
