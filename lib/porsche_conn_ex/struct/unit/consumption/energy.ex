defmodule PorscheConnEx.Struct.Unit.Consumption.Energy do
  @moduledoc """
  Structure representing a ratio of energy consumed versus distance travelled.

  ## Fields

  - `unit` (atom) — units used, depends on locale
    - `:kwh_per_100km` — kilowatt-hours per hundred kilometres (kWh/100km)
    - `:miles_per_kwh` - miles per kilowatt-hour (mi/kWh)
  - `value` (float) — value in above units
  - `kwh_per_100km` (float) — kWh/100km equivalent

  Note that the ratios are inverted for metric versus imperial — metric is
  energy per unit of distance travelled (and lower numbers are more efficient),
  while imperial is distance travelled per unit of energy (and higher numbers are
  more efficient).

  Like most units in this API, a normalised value (`kwh_per_100km`) is
  included, regardless of locale settings.

  Given the numbers returned by the API, it's pretty clear that the values are
  stored in kWh/100km (rounded to one decimal of precision), and are converted
  to mi/kWh for imperial locales.
  """
  use PorscheConnEx.Struct

  enum Unit do
    value(:kwh_per_100km, key: "KWH_PER_100KM")
    value(:miles_per_kwh, key: "MILES_PER_KWH")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:kwh_per_100km, :float, key: "valueKwhPer100Km", required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Consumption.Energy do
  def inspect(energy, _opts) do
    [
      "#{inspect(energy.value)} #{unit(energy.unit)}",
      "#{inspect(energy.kwh_per_100km)} #{unit(:kwh_per_100km)}"
    ]
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PCX:EnergyConsumption<#{inner}>" end)
  end

  defp unit(:kwh_per_100km), do: "kWh/100km"
  defp unit(:miles_per_kwh), do: "mi/kWh"
  defp unit(other), do: inspect(other)
end
