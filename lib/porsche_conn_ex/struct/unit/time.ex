defmodule PorscheConnEx.Struct.Unit.Time do
  @moduledoc """
  Structure representing time.

  Currently only used in `PorscheConnEx.Struct.Status.ServiceInterval`.

  ## Fields

  - `unit` (atom) — unit of time
    - only known value is `:day`
  - `value` (integer) — number of above units
  """

  use PorscheConnEx.Struct

  enum Unit do
    # Only value I've seen so far.
    value(:day, key: "DAYS")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :integer, required: true)
  end

  @type unit :: :day
  @type t :: %__MODULE__{
          unit: unit,
          value: float
        }
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Time do
  def inspect(time, _opts) do
    "#PorscheConnEx.Struct.Unit.Time<#{time.value} #{unit(time.unit, time.value)}>"
  end

  def unit(:day, 1), do: "day"
  def unit(:day, _), do: "days"
  def unit(other, _), do: inspect(other)
end
