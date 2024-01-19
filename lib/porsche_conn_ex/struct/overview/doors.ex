defmodule PorscheConnEx.Struct.Overview.Doors do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Type

  param do
    field(:front_left, Type.Struct.Status.LockStatus, key: "frontLeft", required: true)
    field(:front_right, Type.Struct.Status.LockStatus, key: "frontRight", required: true)
    field(:back_left, Type.Struct.Status.LockStatus, key: "backLeft", required: true)
    field(:back_right, Type.Struct.Status.LockStatus, key: "backRight", required: true)
    field(:trunk, Type.Struct.Status.LockStatus, key: "backTrunk", required: true)
    field(:hood, Type.Struct.Status.LockStatus, key: "frontTrunk", required: true)
    field(:overall, Type.Struct.Status.LockStatus, key: "overallLockStatus", required: true)
  end
end
