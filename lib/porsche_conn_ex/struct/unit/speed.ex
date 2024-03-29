defmodule PorscheConnEx.Struct.Unit.Speed do
  @moduledoc """
  Structure representing units of speed.

  ## Fields

  - `celsius` (atom) — units used, depends on locale
    - `:km_per_hour` — kilometres per hour (km/h)
    - `:mi_per_hour` — miles per hour (mph)
  - `value` (float) — value in above units
  - `km_per_hour` (float) — equivalent value in kilometres per hour

  Like most units in this API, a normalised value (`km_per_hour`) is included,
  regardless of locale settings.

  Given the numbers returned by the API, it's pretty clear that the values are
  stored in km/h (rounded to whole numbers), and are converted to miles per
  hour for imperial locales.
  """

  use PorscheConnEx.Struct

  enum Unit do
    value(:km_per_hour, key: "KMH")
    value(:mi_per_hour, key: "MPH")
  end

  @type unit :: :km_per_hour | :mi_per_hour

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:km_per_hour, :float, key: "valueInKmh", required: true)
  end

  @type t :: %__MODULE__{
          unit: unit,
          value: float,
          km_per_hour: float
        }
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
    |> then(fn inner -> "#PorscheConnEx.Struct.Unit.Speed<#{inner}>" end)
  end

  defp unit(:km_per_hour), do: "km/h"
  defp unit(:mi_per_hour), do: "mph"
  defp unit(other), do: inspect(other)
end
