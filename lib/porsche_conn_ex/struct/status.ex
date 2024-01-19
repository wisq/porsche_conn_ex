defmodule PorscheConnEx.Struct.Status do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type
  alias PorscheConnEx.Struct

  alias __MODULE__.{RemainingRanges, ServiceInterval, OverallLockStatus}

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
