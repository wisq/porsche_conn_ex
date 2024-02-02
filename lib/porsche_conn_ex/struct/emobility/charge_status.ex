defmodule PorscheConnEx.Struct.Emobility.ChargeStatus do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Unit
  alias PorscheConnEx.Struct.Emobility.Timer

  @moduledoc """
  Structure containing information about the electric charging status of a
  particular vehicle.

  ## Fields

  - `mode` (atom) — the current charging mode — `:off`, `:ac`, `:dc`, or `:unknown`
    - `:dc` is currently speculative; I have not tested the API while hooked up to a DC Fast Charger.
  - `plug` (atom) — the status of the physical charging plug — `:connected` or `:disconnected`
  - `plug_lock` (atom) — the lock status of the charging plug — `:locked` or `:unlocked`
  - `state` (atom) — the current charging state — `:off`, `:charging`, `:completed`, or `:error`
  - `reason` (atom or tuple) — the reason for the current charging state
    - `:immediate` if charging due to "direct charge" / user request / etc
    - `{:timer, n}` if charging due to an upcoming timer in slot `n`
    - `:invalid` if there is no reason to charge / charging negotiation is in progess / etc
    - Note that if there is no immediate charging / climatisation activity, this value is unreliable — the API tends to return `{:timer, 4}`, regardless of whether timer #4 is the next timer or not.
  - `external_power` (atom) — the status of the external power connection
    - `:station_connected` when connected to a charging station but not actively drawing power
    - `:available` when actively drawing power from a charging station
    - `:unavailable` when not connected to a charging station
  - `led_color` (atom) — the charging LED colour — `:white`, `:green`, `:blue`, `:red`, or `:off`
  - `led_state` (atom) — the charging LED state — `:flash`, `:blink`, `:pulse`, `:solid`, or `:off`
  - `percent` (integer) — the current percentage of charge (0 to 100)
  - `minutes_to_full` (integer) — the estimated number of minutes until target charge is reached
    - Note that the API appears to calculate this value only when charging parameters change, meaning it will be valid at the start of a charge, but will remain the same (and become quite out of date) until suddenly dropping to zero when charging is complete.
  - `remaining_electric_range` (#{Docs.type(Unit.Distance)}) — the estimated remaining electric travel range
  - `remaining_conventional_range` (#{Docs.type(Unit.Distance)}) — the estimated remaining conventional travel range
  - `rate` (#{Docs.type(Unit.ChargeRate)}) — the current charge rate, in terms of range increase over time
  - `kilowatts` (float) — the current charge rate, in kilowatts
  - `dc_mode?` (boolean) — whether the vehicle is charging in DC mode
    - This appears to refer to DC power, not Direct Charging.  More research needed.
    - If this is redundant due to `mode` above, then I'll remove it.
  - `target_time` (`NaiveDateTime`) — the local time that the vehicle intends to complete its next charge
  - `target_time_opl_enforced` (unknown) — has always been `nil` in testing
    - Sounds like it may be a boolean?
  """

  use PorscheConnEx.Struct

  def field_docs, do: @moduledoc |> Docs.section("Fields")

  enum Mode do
    value(:off, key: "OFF")
    value(:ac, key: "AC")
    # Just guessing here — I need to go hook up to a DC Fast Charger to see if
    # this is the actual code used.  (There may also be other enums that are
    # different when using a DCFC.)
    value(:dc, key: "DC")
    value(:unknown, key: "UNKNOWN")
  end

  @type mode :: :off | :ac | :dc | :unknown

  enum Plug do
    value(:connected, key: "CONNECTED")
    value(:disconnected, key: "DISCONNECTED")
  end

  @type plug :: :connected | :disconnected

  enum PlugLock do
    value(:locked, key: "LOCKED")
    value(:unlocked, key: "UNLOCKED")
  end

  @type plug_lock :: :locked | :unlocked

  enum State do
    value(:off, key: "OFF")
    value(:charging, key: "CHARGING")
    value(:completed, key: "COMPLETED")
    value(:error, key: "ERROR")
  end

  @type state :: :off | :charging | :completed | :error

  defmodule Reason do
    @moduledoc false

    def load("IMMEDIATE"), do: {:ok, :immediate}
    def load("INVALID"), do: {:ok, :invalid}

    # I thought `TIMER4` was just a code and didn't have anything to do with
    # timer numbers, but I've subsequently seen `TIMER3` and `TIMER2` when
    # timers #3 and #2 respectively were waking up the car.
    #
    # I suspect I just saw `TIMER4` a lot because that was my first daily
    # repeating timer.
    def load(<<"TIMER", id::binary-size(1)>>) when id in ~w"1 2 3 4 5" do
      {:ok, {:timer, String.to_integer(id)}}
    end

    def load(other), do: {:error, "Unknown charge reason: #{inspect(other)}"}
  end

  @type reason :: :immediate | :invalid | {:timer, Timer.id()}

  enum ExternalPower do
    value(:station_connected, key: "STATION_CONNECTED")
    value(:available, key: "AVAILABLE")
    value(:unavailable, key: "UNAVAILABLE")
  end

  @type external_power :: :station_connected | :available | :unavailable

  enum LedColor do
    value(:white, key: "WHITE")
    value(:green, key: "GREEN")
    value(:blue, key: "BLUE")
    value(:red, key: "RED")
    value(nil, key: "NONE")
  end

  @type led_color :: :white | :green | :blue | :red | nil

  enum LedState do
    value(:flashing, key: "FLASH")
    value(:blinking, key: "BLINK")
    value(:pulsing, key: "PULSE")
    value(:solid, key: "PERMANENT_ON")
    value(:off, key: "OFF")
  end

  @type led_state :: :flashing | :blinking | :pulsing | :solid | :off

  defmodule TargetTime do
    @moduledoc false
    def load(str), do: Timex.parse(str, "{YYYY}-{0M}-{0D}T{h24}:{m}")
  end

  param do
    field(:mode, Mode, key: "chargingMode", required: true)
    field(:plug, Plug, key: "plugState", required: true)
    field(:plug_lock, PlugLock, key: "lockState", required: true)
    field(:state, State, key: "chargingState", required: true)
    field(:reason, Reason, key: "chargingReason", required: true)
    field(:external_power, ExternalPower, key: "externalPowerSupplyState", required: true)
    field(:led_color, LedColor, key: "ledColor", required: true)
    field(:led_state, LedState, key: "ledState", required: true)
    field(:percent, :integer, key: "stateOfChargeInPercentage", required: true)
    field(:minutes_to_full, :integer, key: "remainingChargeTimeUntil100PercentInMinutes")
    field(:remaining_electric_range, Unit.Distance, key: "remainingERange", required: true)
    field(:remaining_conventional_range, Unit.Distance, key: "remainingCRange")
    field(:rate, Unit.ChargeRate, key: "chargeRate", required: true)
    field(:kilowatts, :float, key: "chargingPower", required: true)
    field(:dc_mode?, :boolean, key: "chargingInDCMode", required: true)

    field(:target_time, TargetTime, key: "chargingTargetDateTime", required: true)
    # No idea what this is.  Always nil for me.
    field(:target_time_opl_enforced, :any, key: "chargingTargetDateTimeOplEnforced")
  end

  @type t :: %__MODULE__{
          mode: mode,
          plug: plug,
          plug_lock: plug_lock,
          state: state,
          reason: reason,
          external_power: external_power,
          led_color: led_color,
          led_state: led_state,
          percent: 0..100,
          minutes_to_full: integer,
          remaining_electric_range: Unit.Distance.t(),
          remaining_conventional_range: Unit.Distance.t(),
          rate: Unit.ChargeRate.t(),
          kilowatts: float,
          dc_mode?: boolean,
          target_time: NaiveDateTime.t(),
          target_time_opl_enforced: any
        }
end
