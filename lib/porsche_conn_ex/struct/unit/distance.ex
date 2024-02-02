defmodule PorscheConnEx.Struct.Unit.Distance do
  @moduledoc """
  Structure representing units of distance.

  ## Fields

  - `unit` (atom) — units used, depends on locale
    - `:km` — kilometres
    - `:mi` — miles
  - `value` (float) — value in above units
  - `original_unit` (atom) — original unit the value was stored in (supposedly, see below)
    - same values as `unit` above
    - *typically* does not vary by locale (but see below)
  - `original_value` (float) — original value
  - `km` (float) — kilometres equivalent

  Like most units in this API, a normalised value (`km`) is included,
  regardless of locale settings.

  Note that `original_unit` is provided by the API, and does not always seem to
  reflect reality.  In most cases, it will always be `:km`, regardless of
  locale.  However, in at least one known case — "remaining range" in an
  [`Overview`](`PorscheConnEx.Struct.Overview`) request — it reported the
  original unit as miles, even though the miles value was a long decimal
  (clearly converted) while the kilometres value was an exact number.

  Meanwhile, the same API call in `de_DE` reported it as originally
  kilometres.  So either "original" means something else in this context, or
  someone's not being entirely truthful.
  """

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
