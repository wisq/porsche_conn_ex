defmodule PorscheConnEx.Struct.Unit.ChargeRate do
  @moduledoc """
  Structure representing rate of battery charge in terms of distance gained per unit time.

  ## Fields

  - `unit` (atom) — units used, depends on locale
    - `:km_per_minute` — kilometres gained per minute of charge
    - `:mi_per_minute` — miles gained per minute of charge
  - `value` (float) — value in above units
  - `km_per_hour` — kilometres gained per hour of charge

  Like most units in this API, a normalised value (`km_per_hour`) is included,
  regardless of locale settings.
  """

  use PorscheConnEx.Struct

  enum Unit do
    value(:km_per_minute, key: "KM_PER_MIN")
    value(:mi_per_minute, key: "MILES_PER_MIN")
  end

  @type unit :: :km_per_minute | :mi_per_minute

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:km_per_hour, :float, key: "valueInKmPerHour", required: true)
  end

  @type t :: %__MODULE__{
          unit: unit,
          value: float,
          km_per_hour: float
        }
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.ChargeRate do
  def inspect(rate, _opts) do
    [
      "#{inspect(rate.value)} #{unit(rate.unit)}",
      "#{inspect(rate.km_per_hour)} #{unit(:km_per_hour)}"
    ]
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PorscheConnEx.Struct.Unit.ChargeRate<#{inner}>" end)
  end

  defp unit(:km_per_minute), do: "km/min"
  defp unit(:km_per_hour), do: "km/h"
  defp unit(:mi_per_minute), do: "mi/min"
  defp unit(other), do: inspect(other)
end
