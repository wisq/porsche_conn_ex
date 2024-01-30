defmodule PorscheConnEx.Struct.Status.RemainingRanges do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Status.Range

  @moduledoc """
  Structure describing the estimated travel distance available for all propulsion systems.

  Used in `PorscheConnEx.Struct.Status` and `PorscheConnEx.Struct.Overview` structures.

  ## Fields

  - `electric` (#{Docs.type(Range)}) — the estimated remaining battery-electric range
  - `conventional` (#{Docs.type(Range)}) — the estimated remaining fuel-burning range
  """

  use PorscheConnEx.Struct

  param do
    field(:electric, Range, key: "electricalRange", required: true)
    field(:conventional, Range, key: "conventionalRange", required: true)
  end
end
