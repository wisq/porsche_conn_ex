defmodule PorscheConnEx.Struct.Position do
  @moduledoc """
  Structure containing the current global position data for a particular vehicle.

  This is the structure returned by `PorscheConnEx.Client.position/2`.

  ## Fields

  - `coordinates` (struct) — the vehicle's geographic coordinates
    - `latitude` (float)
    - `longitude` (float)
    - `reference_system` (atom) — the coordinate reference system
      - `:wgs84` is the only known value so far.
  - `heading` (integer) — the vehicle's compass heading
    - Range is presumed to be 0 to 359.
  """

  use PorscheConnEx.Struct

  enum ReferenceSystem do
    value(:wgs84, key: "WGS84")
  end

  defmodule Coordinates do
    @moduledoc false
    use PorscheConnEx.Struct

    param do
      field(:latitude, :float, required: true)
      field(:longitude, :float, required: true)
      field(:reference_system, ReferenceSystem, key: "geoCoordinateSystem", required: true)
    end
  end

  param do
    field(:coordinates, Coordinates, key: "carCoordinate", required: true)
    field(:heading, :integer, required: true)
  end
end
