defmodule PorscheConnEx.Struct.Emobility.ChargeStatus do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  enum Mode do
    value(:off, key: "OFF")
    value(:ac, key: "AC")
    value(:unknown, key: "UNKNOWN")
  end

  enum Plug do
    value(:connected, key: "CONNECTED")
    value(:disconnected, key: "DISCONNECTED")
  end

  enum PlugLock do
    value(:locked, key: "LOCKED")
    value(:unlocked, key: "UNLOCKED")
  end

  enum State do
    value(:completed, key: "COMPLETED")
    value(:charging, key: "CHARGING")
    value(:error, key: "ERROR")
    value(:off, key: "OFF")
  end

  defmodule Reason do
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

  enum ExternalPower do
    value(:station_connected, key: "STATION_CONNECTED")
    value(:available, key: "AVAILABLE")
    value(:unavailable, key: "UNAVAILABLE")
  end

  enum LedColor do
    value(:white, key: "WHITE")
    value(:green, key: "GREEN")
    value(:blue, key: "BLUE")
    value(:red, key: "RED")
    value(nil, key: "NONE")
  end

  enum LedState do
    value(:flashing, key: "FLASH")
    value(:blinking, key: "BLINK")
    value(:pulsing, key: "PULSE")
    value(:solid, key: "PERMANENT_ON")
    value(:off, key: "OFF")
  end

  defmodule TargetTime do
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
    field(:remaining_electric_range, Struct.Unit.Distance, key: "remainingERange", required: true)
    field(:remaining_conventional_range, Struct.Unit.Distance, key: "remainingCRange")
    field(:target_time, TargetTime, key: "chargingTargetDateTime", required: true)
    field(:rate, Struct.Unit.ChargeRate, key: "chargeRate", required: true)
    field(:kilowatts, :float, key: "chargingPower", required: true)
    field(:dc_mode?, :boolean, key: "chargingInDCMode", required: true)

    # No idea what this is.  Always nil for me.
    field(:target_opl_enforced, :any, key: "chargingTargetDateTimeOplEnforced")
  end
end
