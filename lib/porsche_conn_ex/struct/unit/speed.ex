defmodule PorscheConnEx.Struct.Unit.Speed do
  use PorscheConnEx.Struct

  enum Unit do
    value(:km_per_hour, key: "KMH")
    value(:mi_per_hour, key: "MPH")
  end

  alias __MODULE__.Unit

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:km_per_hour, :float, key: "valueInKmh", required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Speed do
  def inspect(speed, _opts) do
    [
      "#{inspect(speed.value)} #{unit(speed.unit)}",
      "#{inspect(speed.km_per_hour)} #{unit(:km_per_hour)}"
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PCX:Speed<#{inner}>" end)
  end

  defp unit(:km_per_hour), do: "km/h"
  defp unit(:mi_per_hour), do: "mph"
  defp unit(other), do: inspect(other)
end
