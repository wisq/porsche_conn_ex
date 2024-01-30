defmodule PorscheConnEx.Struct.Status.ServiceInterval do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Unit

  @moduledoc """
  Structure describing an upcoming recommended service interval.

  Used in `PorscheConnEx.Struct.Status` and `PorscheConnEx.Struct.Overview` structures.

  ## Fields

  - `distance` (#{Docs.type(Unit.Distance)} or `nil`) — the remaining distance before service is recommended
  - `time` (#{Docs.type(Unit.Time)} or `nil`) — the remaining time before service is recommended

  If a vehicle does not require a particular kind of service — for example, an
  "oil service" for a vehicle without oil — then all fields will be `nil`.
  """

  use PorscheConnEx.Struct

  param do
    field(:distance, Unit.Distance)
    field(:time, Unit.Time)
  end
end

defmodule PorscheConnEx.Struct.Status.ServiceIntervalMap do
  use PorscheConnEx.Type.StructMap, of: PorscheConnEx.Struct.Status.ServiceInterval
end

defmodule PorscheConnEx.Struct.Status.ServiceIntervalNullMap do
  use PorscheConnEx.Type.StructMap,
    of: PorscheConnEx.Struct.Status.ServiceInterval,
    allow_null: true
end
