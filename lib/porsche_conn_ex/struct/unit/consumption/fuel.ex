defmodule PorscheConnEx.Struct.Unit.Consumption.Fuel do
  use PorscheConnEx.Struct

  enum Unit do
    value(:litres_per_100km, key: "LITERS_PER_100_KM")
    value(:miles_per_gallon, key: "MILES_PER_GALLON")
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
