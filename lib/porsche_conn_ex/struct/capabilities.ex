defmodule PorscheConnEx.Struct.Capabilities do
  @moduledoc """
  Structure containing information about the capabilities of a particular vehicle.

  This is the structure returned by `PorscheConnEx.Client.capabilities/2`.

  ## Fields

  - `car_model` (string) — the vehicle platform code (e.g. "J1" for the Taycan)
  - `engine_type` (string) — the type of propulsion system (e.g. "BEV")
  - `has_rdk?` (boolean) — whether the vehicle features the RDK tire pressure monitoring system
  - `has_dx1?` (boolean) — unknown
  - `needs_spin?` (boolean) — unknown
  - `display_parking_brake?` (boolean) — unknown
  - `steering_wheel` (atom) — is the steering wheel on the `:left` or `:right` side?
  - `heating` (struct) — indicates the presence of seat heaters
    - `front_seat?` (boolean) — whether the front seats can be heated
    - `rear_seat?` (boolean) — whether the rear seats can be heated
  """

  use PorscheConnEx.Struct

  enum SteeringWheelPosition do
    value(:left, key: "LEFT")
    value(:right, key: "RIGHT")
  end

  @type steering_wheel_position :: :left | :right

  defmodule Heating do
    @moduledoc false
    use PorscheConnEx.Struct

    param do
      field(:front_seat?, :boolean, key: "frontSeatHeatingAvailable", required: true)
      field(:rear_seat?, :boolean, key: "rearSeatHeatingAvailable", required: true)
    end

    @type t :: %__MODULE__{
            front_seat?: boolean,
            rear_seat?: boolean
          }
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

  @type t :: %__MODULE__{
          car_model: binary,
          engine_type: binary,
          has_rdk?: boolean,
          has_dx1?: boolean,
          needs_spin?: boolean,
          display_parking_brake?: boolean,
          steering_wheel: steering_wheel_position,
          heating: Heating.t()
        }
end
