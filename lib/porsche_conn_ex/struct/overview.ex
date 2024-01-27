defmodule PorscheConnEx.Struct.Overview do
  use PorscheConnEx.Struct
  alias PorscheConnEx.{Struct, Type}

  enum OpenStatus do
    value(:open, key: "OPEN")
    value(:closed, key: "CLOSED")
  end

  enum ActiveStatus do
    value(:active, key: "ACTIVE")
    value(:inactive, key: "INACTIVE")
  end

  enum OnOff do
    value(:on, key: "ON")
    value(:off, key: "OFF")
    value(:completed, key: "COMPLETED")
  end

  enum ChargingState do
    value(:off, key: "OFF")
    value(:charging, key: "CHARGING")
    value(:completed, key: "COMPLETED")
  end

  enum ChargingStatus do
    value(:unplugged, key: "NOT_PLUGGED")
    value(:init, key: "INITIALISING")
    value(:charging, key: "CHARGING")
    value(:completed, key: "CHARGING_COMPLETED")
  end

  param do
    field(:vin, :string, required: true)
    field(:car_model, :string, key: "carModel", required: true)
    field(:engine_type, :string, key: "engineType", required: true)
    field(:mileage, Struct.Unit.Distance, required: true)

    field(:battery_level, Struct.Unit.BatteryLevel, key: "batteryLevel", required: true)
    field(:charging_state, ChargingState, key: "chargingState", required: true)
    field(:charging_status, ChargingStatus, key: "chargingStatus", required: true)

    field(:doors, Struct.Overview.Doors, required: true)
    field(:windows, Struct.Overview.Windows, required: true)
    field(:tires, Struct.Overview.Tires, required: true)
    field(:open_status, OpenStatus, key: "overallOpenStatus", required: true)

    # Note that `brake` is misspelled in the API.
    # The `status` fields are both null for me.
    field(:parking_brake, ActiveStatus, key: "parkingBreak", required: true)
    field(:parking_brake_status, :any, key: "parkingBreakStatus")
    field(:parking_light, OnOff, key: "parkingLight", required: true)
    field(:parking_light_status, :any, key: "parkingLightStatus")
    field(:parking_time, Type.ReverseUtcDateTime, key: "parkingTime", required: true)

    field(:remaining_ranges, Struct.Status.RemainingRanges,
      key: "remainingRanges",
      required: true
    )

    field(:service_intervals, Struct.Status.ServiceIntervalNullMap,
      key: "serviceIntervals",
      required: true
    )

    # Unknown datatypes (null for me):
    field(:oil_level, :any, key: "oilLevel")
    field(:fuel_level, :any, key: "fuelLevel")
  end
end
