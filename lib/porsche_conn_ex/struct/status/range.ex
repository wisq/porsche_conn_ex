defmodule PorscheConnEx.Struct.Status.Range do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Struct.Unit

  @moduledoc """
  Structure describing the estimated travel distance available for a
  given propulsion system.

  Used in `PorscheConnEx.Struct.Status.RemainingRanges` structures.

  ## Fields

  - `engine_type` (atom) — the type of vehicle propulsion system
    - `:electric` for battery-electric propulsion
    - ***TODO:*** *determine value for conventional engines*
    - `nil` if this propulsion method is not supported by this vehicle
  - `primary?` (boolean) — whether this is the vehicle's primary propulsion system
    - Only appears in #{Docs.type(Struct.Overview)} requests, not in #{Docs.type(Struct.Status)} requests.
  - `distance` (#{Docs.type(Unit.Distance)}) — the estimated reamining travel distance available
  """

  use PorscheConnEx.Struct

  enum EngineType do
    value(:electric, key: "ELECTRIC")
    # Someone with a gas car, put your engine type in here. :)
    value(nil, key: "UNSUPPORTED")
  end

  param do
    field(:engine_type, EngineType, key: "engineType", required: true)
    # Only appears in `overview` requests, not `status` ones.
    field(:primary?, :boolean, key: "isPrimary", required: false)
    field(:distance, Unit.Distance, required: false)
  end

  @type engine_type :: :electric
  @type t :: %__MODULE__{
          engine_type: engine_type | nil,
          primary?: boolean | nil,
          distance: Unit.Distance.t() | nil
        }
end
