defmodule PorscheConnEx.Struct.Status do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type
  alias PorscheConnEx.Struct

  defmodule Range do
    use PorscheConnEx.Struct

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

  defmodule RemainingRanges do
    use PorscheConnEx.Struct

    param do
      field(:electrical, Type.struct(Range), key: "electricalRange", required: true)
      field(:conventional, Type.struct(Range), key: "conventionalRange", required: true)
    end
  end

  defmodule OverallLockStatus do
    @enforce_keys [:open, :locked]
    defstruct(@enforce_keys)

    def from_api(term) do
      [open, locked] = String.split(term, "_")

      with {:ok, open} <- open_from_api(open),
           {:ok, locked} <- locked_from_api(locked) do
        {:ok, %__MODULE__{open: open, locked: locked}}
      else
        :error -> {:error, "invalid OverallLockStatus: #{inspect(term)}"}
      end
    end

    defp open_from_api("OPEN"), do: {:ok, true}
    defp open_from_api("CLOSED"), do: {:ok, false}
    defp open_from_api(_), do: :error

    defp locked_from_api("LOCKED"), do: {:ok, true}
    defp locked_from_api("UNLOCKED"), do: {:ok, false}
    defp locked_from_api(_), do: :error
  end

  defmodule ServiceInterval do
    use PorscheConnEx.Struct

    param do
      field(:distance, Type.struct(Struct.Distance))
      field(:time, Type.struct(Struct.Time))
    end
  end

  param do
    field(:vin, :string, required: true)
    field(:battery_level, Type.struct(Struct.BatteryLevel), key: "batteryLevel", required: true)
    field(:mileage, Type.struct(Struct.Distance), required: true)
    field(:remaining_ranges, Type.struct(RemainingRanges), key: "remainingRanges", required: true)

    field(:service_intervals, Type.map_of(ServiceInterval),
      key: "serviceIntervals",
      required: true
    )

    field(:overall_lock_status, Type.struct(OverallLockStatus),
      key: "overallLockStatus",
      required: true
    )

    # Unknown datatypes (null for me):
    #  - fuelLevel
    #  - oilLevel
  end
end
