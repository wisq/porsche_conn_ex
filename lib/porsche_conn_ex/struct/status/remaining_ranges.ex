defmodule PorscheConnEx.Struct.Status.RemainingRanges do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type
  alias PorscheConnEx.Struct.Status.Range

  param do
    field(:electrical, Type.struct(Range), key: "electricalRange", required: true)
    field(:conventional, Type.struct(Range), key: "conventionalRange", required: true)
  end
end
