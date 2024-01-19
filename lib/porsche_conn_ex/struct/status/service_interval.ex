defmodule PorscheConnEx.Struct.Status.ServiceInterval do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type

  param do
    field(:distance, Type.Struct.Distance)
    field(:time, Type.Struct.Time)
  end
end
