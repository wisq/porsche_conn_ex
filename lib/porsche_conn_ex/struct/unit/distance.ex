defmodule PorscheConnEx.Struct.Unit.Distance do
  use PorscheConnEx.Struct

  enum Unit do
    value(:km, key: "KILOMETERS")
    value(:mi, key: "MILES")
  end

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:original_unit, Unit, key: "originalUnit", required: true)
    field(:original_value, :float, key: "originalValue", required: true)
    field(:km, :float, key: "valueInKilometers", required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Distance do
  def inspect(dist, _opts) do
    [
      "#{inspect(dist.value)} #{dist.unit}",
      if dist.original_value && dist.original_unit do
        "#{inspect(dist.original_value)} #{dist.original_unit}"
      else
        nil
      end,
      "#{inspect(dist.km)} km"
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PCX:Distance<#{inner}>" end)
  end
end
