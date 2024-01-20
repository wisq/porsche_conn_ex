defmodule PorscheConnEx.Struct.Status.Range do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  enum EngineType do
    value(:electric, key: "ELECTRIC")
    # Someone with a gas car, put your engine type in here. :)
    value(nil, key: "UNSUPPORTED")
  end

  alias __MODULE__.EngineType

  param do
    field(:engine_type, EngineType, key: "engineType", required: true)
    field(:distance, Struct.Distance, required: false)
    # Only appears in `overview` requests, not `status` ones.
    field(:primary?, :boolean, key: "isPrimary", required: false)
  end
end
