defmodule PorscheConnEx.Struct.Vehicle do
  use PorscheConnEx.Struct

  defmodule Attribute do
    use PorscheConnEx.Struct

    param do
      field(:name, :string, required: true)
      field(:value, :string, required: true)
    end
  end

  defmodule AttributeList do
    use PorscheConnEx.Type.StructList, of: Attribute
  end

  param do
    field(:vin, :string, required: true)
    field(:pcc?, :boolean, key: "isPcc", required: true)
    field(:relationship, :string, required: true)
    field(:model_description, :string, key: "modelDescription", required: true)
    field(:model_type, :string, key: "modelType", required: true)
    field(:model_year, :integer, key: "modelYear", required: true)
    field(:exterior_color, :string, key: "exteriorColor", required: true)
    field(:exterior_color_hex, :string, key: "exteriorColorHex", required: true)
    field(:spin_enabled?, :boolean, key: "spinEnabled", required: true)
    field(:login_method, :string, key: "loginMethod", required: true)
    field(:ota_active?, :boolean, key: "otaActive", required: true)
    field(:valid_from, :datetime, key: "validFrom", required: true)
    field(:attributes, AttributeList, key: "attributes", required: true)
    # Unknown datatype (null for me):
    field(:pending_relationship_termination_at, :any, key: "pendingRelationshipTerminationAt")
  end
end
