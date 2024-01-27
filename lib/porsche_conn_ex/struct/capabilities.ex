defmodule PorscheConnEx.Struct.Capabilities do
  use PorscheConnEx.Struct

  enum SteeringWheelPosition do
    value(:left, key: "LEFT")
    value(:right, key: "RIGHT")
  end

  defmodule Heating do
    use PorscheConnEx.Struct

    param do
      field(:front_seat?, :boolean, key: "frontSeatHeatingAvailable", required: true)
      field(:rear_seat?, :boolean, key: "rearSeatHeatingAvailable", required: true)
    end
  end

  param do
    field(:car_model, :string, key: "carModel", required: true)
    field(:engine_type, :string, key: "engineType", required: true)
    field(:has_rdk?, :boolean, key: "hasRDK", required: true)
    field(:has_dx1?, :boolean, key: "hasDX1", required: true)
    field(:needs_spin?, :boolean, key: "needsSPIN", required: true)
    field(:display_parking_brake?, :boolean, key: "displayParkingBrake", required: true)
    field(:steering_wheel, SteeringWheelPosition, key: "steeringWheelPosition", required: true)
    field(:heating, Heating, key: "heatingCapabilities", required: true)
  end
end
