defmodule PorscheConnEx.Struct.Status do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type

  param do
    field(:vin, :string, required: true)
    field(:battery_level, Type.Struct.BatteryLevel, key: "batteryLevel", required: true)
    field(:mileage, Type.Struct.Distance, required: true)

    field(:remaining_ranges, Type.Struct.Status.RemainingRanges,
      key: "remainingRanges",
      required: true
    )

    field(:service_intervals, Type.Struct.Status.ServiceInterval.Map,
      key: "serviceIntervals",
      required: true
    )

    field(:overall_lock_status, Type.Struct.Status.OverallLockStatus,
      key: "overallLockStatus",
      required: true
    )

    # Unknown datatypes (null for me):
    #  - fuelLevel
    #  - oilLevel
  end
end
