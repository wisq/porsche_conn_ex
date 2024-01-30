defmodule PorscheConnEx.Struct.Emobility.ChargingProfile.Position do
  @moduledoc """
  Structure containing the geographical location at which to activate a
  particular profile.

  ## Fields

  - `latitude` (float) — geographical latitude
  - `longitude` (float) — geographical longitude
  - `radius` (integer) — maximum distance from the given lat/long within which to activate the profile
  """
  use PorscheConnEx.Struct

  param do
    field(:latitude, :float, required: true)
    field(:longitude, :float, required: true)
    field(:radius, :integer, required: true)
  end
end
