defmodule PorscheConnEx.Struct.Unit.Distance do
  @moduledoc """
  Structure representing units of distance.

  ## Fields

  - `unit` (atom) — units used, depends on locale
    - `:km` — kilometres
    - `:mi` — miles
  - `value` (float) — value in above units
  - `km` (float) — kilometres equivalent

  Like most units in this API, a normalised value (`km`) is included,
  regardless of locale settings.
  """

  use PorscheConnEx.Struct

  enum Unit do
    value(:km, key: "KILOMETERS")
    value(:mi, key: "MILES")
  end

  @type unit :: :km | :mi

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:km, :float, key: "valueInKilometers", required: true)
  end

  @type t :: %__MODULE__{
          unit: unit,
          value: float,
          km: float
        }
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Distance do
  def inspect(dist, _opts) do
    [
      "#{inspect(dist.value)} #{dist.unit}",
      "#{inspect(dist.km)} km"
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PorscheConnEx.Struct.Unit.Distance<#{inner}>" end)
  end
end
