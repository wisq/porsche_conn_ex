defmodule PorscheConnEx.Struct.Overview.Doors do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Status.LockStatus

  @moduledoc """
  Structure detailing the open/closed and locked/unlocked state of all vehicle doors.

  ## Fields

  - `front_left` (#{Docs.type(LockStatus)})
  - `front_right` (#{Docs.type(LockStatus)})
  - `back_left` (#{Docs.type(LockStatus)})
  - `back_right` (#{Docs.type(LockStatus)})
  - `trunk` (#{Docs.type(LockStatus)})
  - `hood` (#{Docs.type(LockStatus)}) — always considered unlocked
  - `overall` (#{Docs.type(LockStatus)}) — the overall status of the above (minus `hood`)
  """

  use PorscheConnEx.Struct

  param do
    field(:front_left, LockStatus, key: "frontLeft", required: true)
    field(:front_right, LockStatus, key: "frontRight", required: true)
    field(:back_left, LockStatus, key: "backLeft", required: true)
    field(:back_right, LockStatus, key: "backRight", required: true)
    field(:trunk, LockStatus, key: "backTrunk", required: true)
    field(:hood, LockStatus, key: "frontTrunk", required: true)
    field(:overall, LockStatus, key: "overallLockStatus", required: true)
  end

  @type t :: %__MODULE__{
          front_left: LockStatus.t(),
          front_right: LockStatus.t(),
          back_left: LockStatus.t(),
          back_right: LockStatus.t(),
          trunk: LockStatus.t(),
          hood: LockStatus.t(),
          overall: LockStatus.t()
        }
end
