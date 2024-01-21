defmodule PorscheConnEx.Struct.Emobility.ChargingProfile.Position do
  use PorscheConnEx.Struct

  param do
    field(:latitude, :float, required: true)
    field(:longitude, :float, required: true)
    field(:radius, :integer, required: true)
  end
end
