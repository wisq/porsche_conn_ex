defmodule PorscheConnEx.Struct.Emobility.DirectClimate do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Unit

  @moduledoc """
  Structure containing information about the pre-heat/cool setting of a
  particular vehicle.

  ## Fields

  - `state` (atom) — the current climatisation state — `:on` or `:off`
  - `remaining_minutes` — the remaining time before climatisation will shut down
    - When triggered by a timer, this will be the minutes until the timer is reached.
    - When manually enabled by the user, this will start at 60 minutes.
  - `target_temperature` (#{Docs.type(Unit.Temperature)}) — the temperature that the cabin will be heated/cooled to
  - `heater_source` (atom) — the source of heat for pre-heating
    - `:electric` is the only known value so far.
  - `without_hv_power?` (boolean) — unknown
    - This might refer to whether the vehicle is pulling power from a charging
      station (or the 12V standard car battery?) rather than from the HV battery.
  """

  use PorscheConnEx.Struct

  enum State do
    value(:off, key: "OFF")
    value(:on, key: "ON")
  end

  @type state :: :on | :off

  enum HeaterSource do
    value(:electric, key: "electric")
  end

  @type heater_source :: :electric

  param do
    field(:state, State, key: "climatisationState", required: true)
    field(:remaining_minutes, :integer, key: "remainingClimatisationTime")

    field(:target_temperature, Unit.Temperature,
      key: "targetTemperature",
      required: true
    )

    field(:heater_source, HeaterSource, key: "heaterSource", required: true)
    field(:without_hv_power?, :boolean, key: "climatisationWithoutHVpower", required: true)
  end

  @type t :: %__MODULE__{
          state: state,
          remaining_minutes: integer,
          target_temperature: Unit.Temperature.t(),
          heater_source: heater_source,
          without_hv_power?: boolean
        }
end
