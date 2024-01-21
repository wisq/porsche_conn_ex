defmodule PorscheConnEx.Struct.Emobility.Charging do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  enum Mode do
    value(:off, key: "OFF")
    value(:ac, key: "AC")
    value(:unknown, key: "UNKNOWN")
  end

  enum Plug do
    value(:connected, key: "CONNECTED")
  end

  enum PlugLock do
    value(:locked, key: "LOCKED")
  end

  enum State do
    value(:completed, key: "COMPLETED")
    value(:charging, key: "CHARGING")
  end

  enum Reason do
    # Note that the "4" here does NOT seem to indicate timer number.
    # I see this regardless of the next upcoming timer, and also when
    # charging due to being below the profile minimum.
    value(:schedule, key: "TIMER4")
    # This value is seen when "direct charging" is enabled.
    value(:direct, key: "IMMEDIATE")
  end

  enum ExternalPower do
    value(:station_connected, key: "STATION_CONNECTED")
    value(:available, key: "AVAILABLE")
  end

  enum LedColor do
    value(:green, key: "GREEN")
  end

  enum LedState do
    value(:blinking, key: "BLINK")
    value(:solid, key: "PERMANENT_ON")
  end

  defmodule TargetTime do
    def load(str), do: Timex.parse(str, "{YYYY}-{0M}-{0D}T{h24}:{m}")
  end

  alias __MODULE__.{
    Mode,
    Plug,
    PlugLock,
    State,
    Reason,
    ExternalPower,
    LedColor,
    LedState
  }

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

    field(:minutes_to_full, :integer,
      key: "remainingChargeTimeUntil100PercentInMinutes",
      required: true
    )

    field(:remaining_electric_range, Struct.Distance, key: "remainingERange", required: true)
    field(:remaining_conventional_range, Struct.Distance, key: "remainingCRange")
    field(:target_time, TargetTime, key: "chargingTargetDateTime", required: true)
    field(:rate, Struct.Emobility.ChargeRate, key: "chargeRate", required: true)
    field(:kilowatts, :float, key: "chargingPower", required: true)
    field(:dc_mode?, :boolean, key: "chargingInDCMode", required: true)

    # No idea what this is.  Always nil for me.
    field(:target_opl_enforced, :any, key: "chargingTargetDateTimeOplEnforced")
  end
end
