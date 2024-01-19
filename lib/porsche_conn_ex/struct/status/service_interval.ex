defmodule PorscheConnEx.Struct.Status.ServiceInterval do
  use PorscheConnEx.Struct
  alias PorscheConnEx.{Struct, Type}

  param do
    field(:distance, Type.struct(Struct.Distance))
    field(:time, Type.struct(Struct.Time))
  end
end
