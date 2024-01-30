defmodule PorscheConnEx.Struct.Status do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Unit
  alias __MODULE__, as: S

  @moduledoc """
  Structure containing overview information about a particular vehicle.

  This is the structure returned by `PorscheConnEx.Client.status/2`.

  Note that there is significant overlap between this structure and `PorscheConnEx.Struct.Overview`, and to a lesser degree, with `PorscheConnEx.Struct.Emobility`.

  ## Fields

  - `vin` (string) — the 17-character Vehicle Identification Number
  - `mileage` (#{Docs.type(Unit.Distance)}) — the total distance the vehicle has travelled in its lifetime
  - `battery_level` (#{Docs.type(Unit.BatteryLevel)}) — the battery charge level of the vehicle
  - `remaining_ranges` (#{Docs.type(S.RemainingRanges)}) — the estimated remaining travel ranges, by propulsion type
    - contains #{Docs.count_fields(S.RemainingRanges)} sub-fields
  - `service_intervals` (map of string to #{Docs.type(S.ServiceInterval)}) — upcoming service intervals
  - `doors` (#{Docs.type(S.LockStatus)}) — the overall state of all vehicle doors
  - `oil_level` (unknown) — my Taycan has no oil, this is `nil` for me
  - `fuel_level` (unknown) — my Taycan has no fuel, this is `nil` for me
  """

  use PorscheConnEx.Struct

  param do
    field(:vin, :string, required: true)
    field(:mileage, Unit.Distance, required: true)
    field(:battery_level, Unit.BatteryLevel, key: "batteryLevel", required: true)
    field(:remaining_ranges, S.RemainingRanges, key: "remainingRanges", required: true)
    field(:service_intervals, S.ServiceIntervalMap, key: "serviceIntervals", required: true)
    # Testing indicates this is the same as `PorscheConnEx.Struct.Overview.Doors.overall`.
    # Specifically, it does NOT take windows into account at all.
    # So for clarity, and because `status.doors.open?` looks nicer, I'm simplifying this.
    field(:doors, S.LockStatus, key: "overallLockStatus", required: true)

    # Unknown datatypes (null for me):
    field(:oil_level, :any, key: "oilLevel")
    field(:fuel_level, :any, key: "fuelLevel")
  end
end
