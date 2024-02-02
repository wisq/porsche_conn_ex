defmodule PorscheConnEx.Struct.Maintenance.Task do
  alias PorscheConnEx.Docs
  alias __MODULE__, as: T

  @moduledoc """
  Structure containing information about an upcoming maintenance task.

  ## Fields

  - `id` (string) — a four-digit ID code
  - `criticality` (integer) — unknown (always 1 in testing)
    - Presumably some sort of priority sorting key.
  - `description` (#{Docs.type(T.Description)}) — describes the task to be performed
  - `values` (#{Docs.type(T.Values)}) — task metadata

  These fields have always been `nil` in testing to date, so their datatype is currently not defined:

  - `remaining_days`
  - `remaining_km`
  - `remaining_percent`

  Presumably they'll likely be integers, floats, or unit structures.
  """

  use PorscheConnEx.Struct

  param do
    field(:id, :string, required: true)
    field(:criticality, :integer, required: true)
    field(:description, T.Description, required: true)
    field(:values, T.Values, required: true)
    # These are all null for me, so I won't try to guess the datatype yet.
    field(:remaining_days, :any, key: "remainingLifeTimeInDays")
    field(:remaining_km, :any, key: "remainingLifeTimeInKm")
    field(:remaining_percent, :any, key: "remainingLifeTimePercentage")
  end
end
