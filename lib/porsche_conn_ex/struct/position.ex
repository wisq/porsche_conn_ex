defmodule PorscheConnEx.Struct.Position do
  use PorscheConnEx.Struct

  enum ReferenceSystem do
    value(:wgs84, key: "WGS84")
  end

  alias __MODULE__.{ReferenceSystem}

  defmodule Coordinates do
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
