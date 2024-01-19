defmodule PorscheConnEx.Struct.Overview.Doors do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct

  param do
    field(:front_left, Struct.Status.LockStatus, key: "frontLeft", required: true)
    field(:front_right, Struct.Status.LockStatus, key: "frontRight", required: true)
    field(:back_left, Struct.Status.LockStatus, key: "backLeft", required: true)
    field(:back_right, Struct.Status.LockStatus, key: "backRight", required: true)
    field(:trunk, Struct.Status.LockStatus, key: "backTrunk", required: true)
    field(:hood, Struct.Status.LockStatus, key: "frontTrunk", required: true)
    field(:overall, Struct.Status.LockStatus, key: "overallLockStatus", required: true)
  end
end
