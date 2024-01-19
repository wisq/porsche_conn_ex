defmodule PorscheConnEx.Type do
  defdelegate struct(module), to: PorscheConnEx.Type.Struct
  defdelegate list_of(module), to: PorscheConnEx.Type.Struct
  defdelegate map_of(module), to: PorscheConnEx.Type.Struct
end
