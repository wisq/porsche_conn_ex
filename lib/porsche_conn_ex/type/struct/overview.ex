defmodule PorscheConnEx.Type.Struct.Overview do
  defmodule Doors do
    use PorscheConnEx.Type.Struct, for: PorscheConnEx.Struct.Overview.Doors
  end

  defmodule Windows do
    use PorscheConnEx.Type.Struct, for: PorscheConnEx.Struct.Overview.Windows
  end

  defmodule TirePressure.Map do
    use PorscheConnEx.Type.StructMap, of: PorscheConnEx.Struct.Overview.TirePressure
  end
end
