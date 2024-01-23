defmodule PorscheConnEx.Struct.Status do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  param do
    field(:vin, :string, required: true)
    field(:battery_level, Struct.Unit.BatteryLevel, key: "batteryLevel", required: true)
    field(:mileage, Struct.Unit.Distance, required: true)

    field(:remaining_ranges, Struct.Status.RemainingRanges,
      key: "remainingRanges",
      required: true
    )

    field(:service_intervals, Struct.Status.ServiceIntervalMap,
      key: "serviceIntervals",
      required: true
    )

    field(:overall_lock_status, Struct.Status.LockStatus,
      key: "overallLockStatus",
      required: true
    )

    # Unknown datatypes (null for me):
    field(:oil_level, :any, key: "oilLevel")
    field(:fuel_level, :any, key: "fuelLevel")
  end
end
