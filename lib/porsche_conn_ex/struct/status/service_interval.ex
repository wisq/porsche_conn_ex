defmodule PorscheConnEx.Struct.Status.ServiceInterval do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  param do
    field(:distance, Struct.Unit.Distance)
    field(:time, Struct.Unit.Time)
  end
end

defmodule PorscheConnEx.Struct.Status.ServiceIntervalMap do
  use PorscheConnEx.Type.StructMap, of: PorscheConnEx.Struct.Status.ServiceInterval
end

defmodule PorscheConnEx.Struct.Status.ServiceIntervalNullMap do
  use PorscheConnEx.Type.StructMap,
    of: PorscheConnEx.Struct.Status.ServiceInterval,
    allow_null: true
end
