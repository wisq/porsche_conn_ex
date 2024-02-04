defmodule PorscheConnEx.Struct.Unit.Pressure do
  @moduledoc """
  Structure representing units of pressure.

  ## Fields

  - `unit` (atom) — units used, depends on locale
    - `:bar` — bar
    - `:psi` — pounds per square inch
  - `value` (float) — value in above units
  - `bar` (float) — equivalent value in bar

  Like most units in this API, a normalised value (`bar`) is included,
  regardless of locale settings.

  Given the numbers returned by the API, it's pretty clear that the values are
  are stored in bar (with one decimal of precision), and are converted to PSI
  for imperial locales.
  """
  use PorscheConnEx.Struct

  enum Unit do
    value(:bar, key: "BAR")
    value(:psi, key: "PSI")
  end

  @type unit :: :bar | :psi

  param do
    field(:unit, Unit, required: true)
    field(:value, :float, required: true)
    field(:bar, :float, key: "valueInBar", required: true)
  end

  @type t :: %__MODULE__{
          unit: unit,
          value: float,
          bar: float
        }
end

defimpl Inspect, for: PorscheConnEx.Struct.Unit.Pressure do
  def inspect(pressure, _opts) do
    [
      "#{inspect(pressure.value)} #{unit(pressure.unit)}",
      "#{inspect(pressure.bar)} #{unit(:bar)}"
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.join(" / ")
    |> then(fn inner -> "#PorscheConnEx.Struct.Unit.Pressure<#{inner}>" end)
  end

  defp unit(:bar), do: "bar"
  defp unit(:psi), do: "psi"
end
