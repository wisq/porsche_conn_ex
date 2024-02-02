defmodule PorscheConnEx.Struct.Overview.Windows do
  @moduledoc """
  Structure containing information about the open/closed state of all windows.

  ## Fields

  - `front_left` (open status)
  - `front_right` (open status)
  - `back_left` (open status)
  - `back_right` (open status)
  - `maintenance_hatch` (open status)
  - `roof` (open status)
  - `sunroof` (struct)
    - `position` (integer) — the sunroof open position as a percent value
    - `status` (open status)

  All "open status" fields will be either `:open`, `:closed`, or `nil` if not
  present on the vehicle.
  """

  use PorscheConnEx.Struct

  enum OpenStatus do
    value(:open, key: "OPEN")
    value(:closed, key: "CLOSED")
    value(nil, key: "UNSUPPORTED")
  end

  @type open_status :: :open | :closed | nil

  defmodule Sunroof do
    @moduledoc false
    use PorscheConnEx.Struct

    param do
      # I've not seen this as anything other than `nil`, but based on the name,
      # I'm going to assume it's an integer.
      field(:position, :integer, key: "positionInPercent")
      field(:status, OpenStatus, required: true)
    end
  end

  param do
    field(:front_left, OpenStatus, key: "frontLeft", required: true)
    field(:front_right, OpenStatus, key: "frontRight", required: true)
    field(:back_left, OpenStatus, key: "backLeft", required: true)
    field(:back_right, OpenStatus, key: "backRight", required: true)
    field(:maintenance_hatch, OpenStatus, key: "maintenanceHatch", required: true)
    field(:roof, OpenStatus, required: true)
    field(:sunroof, Sunroof, required: true)
  end

  @type t :: %__MODULE__{
          front_left: open_status,
          front_right: open_status,
          back_left: open_status,
          back_right: open_status,
          maintenance_hatch: open_status,
          roof: open_status,
          sunroof: open_status
        }
end
