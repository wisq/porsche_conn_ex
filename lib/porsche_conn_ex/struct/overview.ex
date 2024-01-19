defmodule PorscheConnEx.Struct.Overview do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type

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
  end

  alias __MODULE__.{OpenStatus, ActiveStatus, OnOff}

  param do
    field(:vin, :string, required: true)
    field(:battery_level, Type.Struct.BatteryLevel, key: "batteryLevel", required: true)
    field(:car_model, :string, key: "carModel", required: true)
    field(:mileage, Type.Struct.Distance, required: true)

    # Note that `brake` is misspelled in the API.
    # The `status` fields are null for me.
    field(:parking_brake, ActiveStatus, key: "parkingBreak", required: true)
    field(:parking_brake_status, :any, key: "parkingBreakStatus")
    field(:parking_light, OnOff, key: "parkingLight", required: true)
    field(:parking_light_status, :any, key: "parkingLightStatus")

    field(:remaining_ranges, Type.Struct.Status.RemainingRanges,
      key: "remainingRanges",
      required: true
    )

    field(:service_intervals, Type.Struct.Status.ServiceInterval.MapOrNull,
      key: "serviceIntervals",
      required: true
    )

    field(:engine_type, :string, key: "engineType", required: true)

    field(:doors, Type.Struct.Overview.Doors, required: true)
    field(:windows, Type.Struct.Overview.Windows, required: true)

    field(:charging_state, :any, key: "chargingState", required: true)
    field(:charging_status, :any, key: "chargingStatus", required: true)

    field(:tires, Type.Struct.Overview.TirePressure.Map, required: true)
    field(:overall_open_status, OpenStatus, key: "overallOpenStatus", required: true)
    field(:parking_time, Type.ReverseUtcDateTime, key: "parkingTime", required: true)

    # Unknown datatypes (null for me):
    field(:oil_level, :any, key: "oilLevel")
    field(:fuel_level, :any, key: "fuelLevel")
  end
end
