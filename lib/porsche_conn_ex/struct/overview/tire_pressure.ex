defmodule PorscheConnEx.Struct.Overview.TirePressure do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Unit

  @moduledoc """
  Structure detailing the pressure and status of a single tire.

  ## Fields

  - `current` (#{Docs.type(Unit.Pressure)} or `nil`) — the current tire pressure
  - `optimal` (#{Docs.type(Unit.Pressure)} or `nil`) — the optimal tire pressure
  - `difference` (#{Docs.type(Unit.Pressure)} or `nil`) - the difference between the above
  - `status` (atom) — the overall tire pressure status
    - ***TODO:*** *I have not seen what value is returned when pressure is correct.*
    - `:divergent` if the current pressure deviates from the optimal pressure.
    - `nil` if tire pressure data is not available.

  The Porsche tire pressure monitoring system requires that the vehicle be
  moving.  When the vehicle is parked and does not have recent tire pressure
  data, all of the above will be `nil`.
  """

  use PorscheConnEx.Struct

  enum Status do
    value(nil, key: "UNKNOWN")
    # Only known value I've seen so far.
    value(:divergent, key: "DIVERGENT")
  end

  @type status :: :divergent

  param do
    field(:current, Unit.Pressure, key: "currentPressure")
    field(:optimal, Unit.Pressure, key: "optimalPressure")
    field(:difference, Unit.Pressure, key: "differencePressure")
    field(:status, Status, key: "tirePressureDifferenceStatus", required: true)
  end

  @type t :: %__MODULE__{
          current: Unit.Pressure.t() | nil,
          optimal: Unit.Pressure.t() | nil,
          difference: Unit.Pressure.t() | nil,
          status: status | nil
        }
end
