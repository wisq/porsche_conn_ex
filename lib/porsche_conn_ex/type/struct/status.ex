defmodule PorscheConnEx.Type.Struct.Status do
  defmodule RemainingRanges do
    use PorscheConnEx.Type.Struct, for: PorscheConnEx.Struct.Status.RemainingRanges
  end

  defmodule Range do
    use PorscheConnEx.Type.Struct, for: PorscheConnEx.Struct.Status.Range
  end

  defmodule ServiceInterval.Map do
    use PorscheConnEx.Type.StructMap, of: PorscheConnEx.Struct.Status.ServiceInterval
  end

  defmodule OverallLockStatus do
    use PorscheConnEx.Type.Struct, for: PorscheConnEx.Struct.Status.OverallLockStatus
  end
end
