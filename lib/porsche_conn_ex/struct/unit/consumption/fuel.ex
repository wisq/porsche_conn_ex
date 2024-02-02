defmodule PorscheConnEx.Struct.Unit.Consumption.Fuel do
  @moduledoc """
  Structure representing a ratio of fuel consumed versus distance travelled.

  ## Fields

  - `unit` (atom) — units used, depends on locale
    - `:litres_per_100km` — litres of fuel per hundred kilometres (L/100km)
    - `:miles_per_gallon` - miles per gallon of fuel (mpg)
  - `value` (float) — value in above units
  - `litres_per_100km` (float) — L/100km equivalent

  Note that the ratios are inverted for metric versus imperial — metric is fuel
  per unit of distance travelled (and lower numbers are more efficient), while
  imperial is distance travelled per unit of fuel (and higher numbers are more
  efficient).

  Like most units in this API, a normalised value (`litres_per_100km`) is
  included, regardless of locale settings.

  There is no `original_unit` field provided for this unit, and since my car
  does not use fuel, I cannot report on the original unit or the expected
  precision of fuel consumption values.  However, if this unit follows the
  trend of other units in this API, it's likely that the metric value is the
  original precise value, and the imperial value is a conversion of that.
  """
  use PorscheConnEx.Struct

  enum Unit do
    value(:litres_per_100km, key: "LITERS_PER_100_KM")
    value(:miles_per_gallon, key: "MILES_PER_GALLON_US")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:litres_per_100km, :float, key: "valueInLitersPer100Km", required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Consumption.Fuel do
  def inspect(fuel, _opts) do
    [
      "#{inspect(fuel.value)} #{unit(fuel.unit)}",
      "#{inspect(fuel.litres_per_100km)} #{unit(:litres_per_100km)}"
    ]
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PCX:FuelConsumption<#{inner}>" end)
  end

  defp unit(:litres_per_100km), do: "L/100km"
  defp unit(:miles_per_gallon), do: "mpg"
  defp unit(other), do: inspect(other)
end
