defmodule PorscheConnEx.Struct.Trip do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Unit

  @moduledoc """
  Structure containing trip data — distance, speed, efficiency, etc.

  This is the structure returned by `PorscheConnEx.Client.trips_short_term/2`
  and `PorscheConnEx.Client.trips_long_term/2`.

  ## Fields

  - `id` (integer) — the internal trip ID
  - `type` (atom) — the type of trip
    - `:short_term` for `trips_short_term/2` calls
    - `:long_term` for `trips_long_term/2` calls
  - `timestamp` (`DateTime`) — the UTC timestamp the trip ended at
  - `minutes` (integer) — the duration of the trip, in minutes
  - `start_mileage` (#{Docs.type(Unit.Distance)}) — the total vehicle miles travelled prior to this trip
  - `end_mileage` (#{Docs.type(Unit.Distance)}) — the total vehicle miles travelled at the end of this trip
  - `distance` (#{Docs.type(Unit.Distance)}) — the distance travelled during this trip
  - `average_speed` (#{Docs.type(Unit.Speed)}) — the average speed during the trip
    - This should generally be similar to `distance / minutes`, although there appears to be some rounding.
  - `zero_emission_distance` (#{Docs.type(Unit.Distance)}) — distanc travelled using a zero-emission energy source (e.g. battery)
  - `average_fuel_consumption` (#{Docs.type(Unit.Consumption.Fuel)}) — average fuel efficiency during the trip
  - `average_energy_consumption` (#{Docs.type(Unit.Consumption.Energy)}) — average energy efficiency during the trip
  """

  use PorscheConnEx.Struct

  enum Type do
    value(:long_term, key: "LONG_TERM")
    value(:short_term, key: "SHORT_TERM")
  end

  param do
    field(:id, :integer, required: true)
    field(:type, Type, required: true)
    field(:timestamp, :datetime, required: true)
    field(:minutes, :integer, key: "travelTime", required: true)

    field(:start_mileage, Unit.Distance, key: "startMileage", required: true)
    field(:end_mileage, Unit.Distance, key: "endMileage", required: true)
    field(:distance, Unit.Distance, key: "tripMileage", required: true)
    field(:average_speed, Unit.Speed, key: "averageSpeed", required: true)

    field(:zero_emission_distance, Unit.Distance,
      key: "zeroEmissionDistance",
      required: true
    )

    field(:average_fuel_consumption, Unit.Consumption.Fuel,
      key: "averageFuelConsumption",
      required: true
    )

    field(:average_energy_consumption, Unit.Consumption.Energy,
      key: "averageElectricEngineConsumption",
      required: true
    )
  end

  @type t :: %__MODULE__{
          id: integer,
          type: atom,
          timestamp: DateTime.t(),
          minutes: integer,
          start_mileage: Unit.Distance.t(),
          end_mileage: Unit.Distance.t(),
          distance: Unit.Distance.t(),
          average_speed: Unit.Speed.t(),
          zero_emission_distance: Unit.Distance.t(),
          average_fuel_consumption: Unit.Consumption.Fuel.t(),
          average_energy_consumption: Unit.Consumption.Energy.t()
        }
end
