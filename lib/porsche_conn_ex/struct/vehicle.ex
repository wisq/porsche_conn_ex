defmodule PorscheConnEx.Struct.Vehicle do
  use Parameter.Schema

  param do
    field(:vin, :string, required: true)
    field(:is_pcc, :boolean, key: "isPcc", required: true)
    field(:relationship, :string, required: true)
    field(:model_description, :string, key: "modelDescription", required: true)
    field(:model_type, :string, key: "modelType", required: true)
    field(:model_year, :integer, key: "modelYear", required: true)
    field(:exterior_color, :string, key: "exteriorColor", required: true)
    field(:exterior_color_hex, :string, key: "exteriorColorHex", required: true)
    field(:spin_enabled, :boolean, key: "spinEnabled", required: true)
    field(:login_method, :string, key: "loginMethod", required: true)
    field(:ota_active, :boolean, key: "otaActive", required: true)
    field(:valid_from, :datetime, key: "validFrom", required: true)

    # Never seen this not-nil, but I'm assuming it'll be a datetime.
    field(:pending_relationship_termination_at, :datetime,
      key: "pendingRelationshipTerminationAt"
    )

    # Not sure what type this will be, mine's empty.
    field(:attributes, {:array, :string}, key: "attributes", required: true)
  end

  def from_api(params) do
    case Parameter.load(__MODULE__, params) do
      {:ok, fields} -> {:ok, struct!(__MODULE__, fields)}
      {:error, _} = err -> err
    end
  end

  def to_api(%__MODULE__{} = struct), do: Parameter.dump(__MODULE__, struct)
end
