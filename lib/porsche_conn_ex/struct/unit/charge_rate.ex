defmodule PorscheConnEx.Struct.Unit.ChargeRate do
  use PorscheConnEx.Struct

  enum Unit do
    value(:km_per_minute, key: "KM_PER_MIN")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:km_per_hour, :float, key: "valueInKmPerHour", required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.ChargeRate do
  def inspect(rate, _opts) do
    [
      "#{inspect(rate.value)} #{unit(rate.unit)}",
      "#{inspect(rate.km_per_hour)} #{unit(:km_per_hour)}"
    ]
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PCX:ChargeRate<#{inner}>" end)
  end

  defp unit(:km_per_minute), do: "km/m"
  defp unit(:km_per_hour), do: "km/h"
  defp unit(other), do: inspect(other)
end
