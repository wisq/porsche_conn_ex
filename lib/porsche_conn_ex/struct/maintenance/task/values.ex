defmodule PorscheConnEx.Struct.Maintenance.Task.Values do
  @moduledoc """
  Structure containing metadata about a maintenance task.

  ## Fields

  - `model_id` (string) — a four-digit ID code
    - Seems to generally be the same as the ID code of the containing task.
  - `model_state` (atom) — unknown
    - only `:active` seen so far
  - `model_name` (string) — the name of the part to be replaced
    - This is generally always in German, regardless of locale.
  - `model_visibility` (atom) — unknown
    - only `:visible` seen so far
  - `source` (atom) — unknown
    - only `:vehicle` seen so far
  - `event` (atom) — unknown
    - only `:cyclic` seen so far
  - `odometer_last_reset` (integer) — unknown
    - Might be the odometer reading when the task was last performed.
  - `criticality` (integer) — unknown
    - Presumably some sort of priority sorting key.
    - Seems to generally be the same as the criticality of the containing task.
  - `warnings` (map of `integer => integer`) — unknown
    - In the raw data, these are represented as e.g. `"WarnID294" : "0"`.
    - This gets translated into `294 => 0` in our `warnings` map.
    - It's possible that the warning codes are UI localisation keys, and the values are whether to show them or not?  (No values other than `"0"` have been seen so far.)
  """

  use PorscheConnEx.Struct

  # I've only seen one value for all these enums so far.
  # If you've seen different values, please let me know!

  enum ModelState do
    value(:active, key: "active")
  end

  @type model_state :: :active

  enum ModelVisibility do
    value(:visible, key: "visible")
  end

  @type model_visibility :: :visible

  enum Source do
    value(:vehicle, key: "Vehicle")
  end

  @type source :: :vehicle

  enum Event do
    value(:cyclic, key: "CYCLIC")
  end

  @type event :: :cyclic

  param do
    field(:model_id, :string, key: "modelId", required: true)
    field(:model_state, ModelState, key: "modelState", required: true)
    field(:model_name, :string, key: "modelName", required: true)
    field(:model_visibility, ModelVisibility, key: "modelVisibilityState", required: true)
    field(:source, Source, required: true)
    field(:event, Event, required: true)
    field(:odometer_last_reset, :integer, key: "odometerLastReset", required: true)
    field(:criticality, :integer, required: true)
    field(:warnings, {:map, :integer}, required: true)
  end

  @type t :: %__MODULE__{
          model_id: binary,
          model_state: model_state,
          model_name: binary,
          model_visibility: model_visibility,
          source: source,
          event: event,
          odometer_last_reset: integer,
          criticality: integer,
          warnings: %{optional(integer) => integer}
        }

  def load(params) when is_map(params) do
    {warnings, params} =
      params
      |> Map.split_with(fn
        {"WarnID" <> _, _} -> true
        {_, _} -> false
      end)

    warnings =
      warnings
      |> Map.new(fn {"WarnID" <> id, value} ->
        {String.to_integer(id), value}
      end)

    params
    |> Map.put("warnings", warnings)
    |> super()
  end
end
