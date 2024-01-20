defmodule PorscheConnEx.Struct.Overview.Tires do
  use PorscheConnEx.Struct
  alias PorscheConnEx.Struct.Overview.TirePressure

  param do
    field(:front_left, TirePressure, key: "frontLeft", required: true)
    field(:front_right, TirePressure, key: "frontRight", required: true)
    field(:back_left, TirePressure, key: "backLeft", required: true)
    field(:back_right, TirePressure, key: "backRight", required: true)
  end
end
