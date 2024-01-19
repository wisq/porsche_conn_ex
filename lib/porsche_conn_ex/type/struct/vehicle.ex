defmodule PorscheConnEx.Type.Struct.Vehicle do
  defmodule Attribute.List do
    use PorscheConnEx.Type.StructList, of: PorscheConnEx.Struct.Vehicle.Attribute
  end
end
