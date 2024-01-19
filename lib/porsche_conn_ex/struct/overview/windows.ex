defmodule PorscheConnEx.Struct.Overview.Windows do
  use PorscheConnEx.Struct

  enum OpenStatus do
    value(:open, key: "OPEN")
    value(:closed, key: "CLOSED")
    value(:unsupported, key: "UNSUPPORTED")
  end

  alias __MODULE__.OpenStatus

  defmodule Sunroof do
    use PorscheConnEx.Struct

    param do
      field(:percent, :any, key: "positionInPercent")
      field(:status, OpenStatus, required: true)
    end

    def load(x), do: from_api(x)
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
end
