defmodule PorscheConnEx.Struct.Status.Range do
  use PorscheConnEx.Struct
  alias PorscheConnEx.{Struct, Type}

  enum EngineType do
    value(:electric, key: "ELECTRIC")
    # Someone with a gas car, put your engine type in here. :)
    value(nil, key: "UNSUPPORTED")
  end

  alias __MODULE__.EngineType

  param do
    field(:engine_type, EngineType, key: "engineType", required: true)
    field(:is_primary, :boolean, key: "isPrimary", required: false)
    field(:distance, Type.struct(Struct.Distance), required: false)
  end
end
