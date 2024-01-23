defmodule PorscheConnEx.Struct.Unit.Consumption.Energy do
  use PorscheConnEx.Struct

  enum Unit do
    value(:kwh_per_100km, key: "KWH_PER_100KM")
    value(:miles_per_kwh, key: "MILES_PER_KWH")
  end

  alias __MODULE__.Unit

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
