defmodule PorscheConnEx.Struct.Overview do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.{Struct, Type}
  alias PorscheConnEx.Struct.Unit
  alias __MODULE__, as: O
  alias PorscheConnEx.Struct.Status, as: S

  @moduledoc """
  Structure containing overview information about a particular vehicle.

  This is the structure returned by `PorscheConnEx.Client.stored_overview/2`
  and `PorscheConnEx.Client.current_overview/2`.

  ## Fields

  - `vin` (string) — the 17-character Vehicle Identification Number
  - `car_model` (string ✱) — the vehicle platform code (e.g. "J1" for the Taycan)
  - `engine_type` (string ✱) — the type of propulsion system (e.g. "BEV")
  - `mileage` (#{Docs.type(Unit.Distance)}) — the total distance the vehicle has travelled in its lifetime
  - `battery_level` (#{Docs.type(Unit.BatteryLevel)}) — the battery charge level of the vehicle
  - `charging_state` (atom ✱) — the battery charging state — `:off`, `:charging`, or `:completed`
  - `charging_status` (atom ✱) — a more detailed battery charging state
    - `:unplugged` if the vehicle is not connected to a charging station
    - `:init` if the vehicle is negotiating with the charging station to begin charging
    - `:charging` if the vehicle is charging
    - `:completed` if the vehicle has finished charging
  - `doors` (#{Docs.type(O.Doors)}) — the open/closed and locked/unlocked state of all doors
    - contains #{Docs.count_fields(O.Doors)} sub-fields
  - `windows` (#{Docs.type(O.Windows)}) — the open/closed state of all windows
    - contains #{Docs.count_fields(O.Windows)} sub-fields
  - `open?` (booelan) — the overall open/closed status of the vehicle
    - This will be true if any door is unlocked, or any door/window is open.
    - Ignores the status of the hood.
  - `tires` (#{Docs.type(O.Tires)}) — the pressure and status of all tires
    - contains #{Docs.count_fields(O.Tires)} sub-fields
  - `parking_brake?` (boolean) — whether the parking brake is engaged
  - `parking_brake_status` (unknown) — has always been `nil` in testing
  - `parking_light` (atom) — whether the `:left` or `:right` parking lights are engaged, or `:off`
  - `parking_light_status` (unknown) — has always been `nil` in testing
  - `parking_time` (`DateTime`) — the UTC time when the vehicle was last parked
  - `remaining_ranges` (#{Docs.type(S.RemainingRanges)}) — the estimated remaining travel ranges, by propulsion type
    - contains #{Docs.count_fields(S.RemainingRanges)} sub-fields
  - `service_intervals` (map of string to #{Docs.type(S.ServiceInterval)}) — upcoming service intervals
    - Some entries map a string to `nil`, presumably to indicate no such service is requried.
  - `oil_level` (unknown) — my Taycan has no oil, this is `nil` for me
  - `fuel_level` (unknown) — my Taycan has no fuel, this is `nil` for me

  Fields marked with "✱" may be `nil` when queried via [`current_overview/2`](`PorscheConnEx.Client.current_overview/2`).
  """
  use PorscheConnEx.Struct

  enum OpenStatus do
    value(true, key: "OPEN")
    value(false, key: "CLOSED")
  end

  enum ParkingBrake do
    value(true, key: "ACTIVE")
    value(false, key: "INACTIVE")
  end

  enum ParkingLight do
    value(:off, key: "OFF")
    value(:left, key: "LEFT_ON")
    value(:right, key: "RIGHT_ON")
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
    field(:car_model, :string, key: "carModel")
    field(:engine_type, :string, key: "engineType")
    field(:mileage, Struct.Unit.Distance, required: true)

    field(:battery_level, Unit.BatteryLevel, key: "batteryLevel", required: true)
    field(:charging_state, ChargingState, key: "chargingState")
    field(:charging_status, ChargingStatus, key: "chargingStatus")

    field(:doors, O.Doors, required: true)
    field(:windows, O.Windows, required: true)
    field(:open?, OpenStatus, key: "overallOpenStatus", required: true)
    field(:tires, O.Tires, required: true)

    # Note that `brake` is misspelled in the API.
    field(:parking_brake?, ParkingBrake, key: "parkingBreak", required: true)
    field(:parking_brake_status, :any, key: "parkingBreakStatus")
    field(:parking_light, ParkingLight, key: "parkingLight", required: true)
    field(:parking_light_status, :any, key: "parkingLightStatus")
    field(:parking_time, Type.ReverseUtcDateTime, key: "parkingTime")

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
