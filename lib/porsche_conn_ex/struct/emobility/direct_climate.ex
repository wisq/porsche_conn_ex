defmodule PorscheConnEx.Struct.Emobility.DirectClimate do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  enum State do
    value(:off, key: "OFF")
    value(:on, key: "ON")
  end

  enum HeaterSource do
    value(:electric, key: "electric")
  end

  param do
    field(:state, State, key: "climatisationState", required: true)
    field(:without_hv_power, :boolean, key: "climatisationWithoutHVpower", required: true)
    field(:remaining_minutes, :integer, key: "remainingClimatisationTime")
    field(:heater_source, HeaterSource, key: "heaterSource", required: true)

    field(:target_temperature, Struct.Unit.Temperature,
      key: "targetTemperature",
      required: true
    )
  end
end
