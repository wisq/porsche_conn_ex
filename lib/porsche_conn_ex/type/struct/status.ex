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

  defmodule ServiceInterval.MapOrNull do
    use PorscheConnEx.Type.StructMap,
      of: PorscheConnEx.Struct.Status.ServiceInterval,
      allow_null: true
  end

  defmodule LockStatus do
    use PorscheConnEx.Type.Struct, for: PorscheConnEx.Struct.Status.LockStatus
  end
end
