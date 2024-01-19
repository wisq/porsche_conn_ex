defmodule PorscheConnEx.Struct.Status.RemainingRanges do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  param do
    field(:electrical, Struct.Status.Range, key: "electricalRange", required: true)
    field(:conventional, Struct.Status.Range, key: "conventionalRange", required: true)
  end
end
