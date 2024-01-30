defmodule PorscheConnEx.Struct.Overview.Tires do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Overview.TirePressure

  @moduledoc """
  Structure containing information about the pressure and status of all tires.

  ## Fields

  - `front_left` (#{Docs.type(TirePressure)})
  - `front_right` (#{Docs.type(TirePressure)})
  - `back_left` (#{Docs.type(TirePressure)})
  - `back_right` (#{Docs.type(TirePressure)})
  """

  use PorscheConnEx.Struct

  param do
    field(:front_left, TirePressure, key: "frontLeft", required: true)
    field(:front_right, TirePressure, key: "frontRight", required: true)
    field(:back_left, TirePressure, key: "backLeft", required: true)
    field(:back_right, TirePressure, key: "backRight", required: true)
  end
end
