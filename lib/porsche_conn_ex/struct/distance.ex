defmodule PorscheConnEx.Struct.Distance do
  use PorscheConnEx.Struct

  enum Unit do
    value(:km, key: "KILOMETERS")
    value(:mi, key: "MILES")
  end

  alias __MODULE__.Unit

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:original_unit, Unit, key: "originalUnit", required: true)
    field(:original_value, :float, key: "originalValue", required: true)
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Distance do
  def inspect(dist, _opts) do
    [
      "#{inspect(dist.value)} #{dist.unit}",
      if dist.original_value && dist.original_unit do
        "#{inspect(dist.original_value)} #{dist.original_unit}"
      else
        nil
      end
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.join(" ")
    |> then(fn inner -> "#PCX:Distance<#{inner}>" end)
  end
end
