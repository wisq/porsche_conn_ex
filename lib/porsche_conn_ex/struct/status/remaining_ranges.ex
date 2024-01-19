defmodule PorscheConnEx.Struct.Status.RemainingRanges do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type

  param do
    field(:electrical, Type.Struct.Status.Range, key: "electricalRange", required: true)
    field(:conventional, Type.Struct.Status.Range, key: "conventionalRange", required: true)
  end
end
