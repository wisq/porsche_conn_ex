defmodule PorscheConnEx.Struct.Trip do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct.Unit

  enum Type do
    value(:long_term, key: "LONG_TERM")
    value(:short_term, key: "SHORT_TERM")
  end

  param do
    field(:id, :integer, required: true)
    field(:type, Type, required: true)
    field(:timestamp, :datetime, required: true)

    field(:distance, Unit.Distance, key: "tripMileage", required: true)
    field(:minutes, :integer, key: "travelTime", required: true)
    field(:average_speed, Unit.Speed, key: "averageSpeed", required: true)

    field(:start_mileage, Unit.Distance, key: "startMileage", required: true)
    field(:end_mileage, Unit.Distance, key: "endMileage", required: true)

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
end
