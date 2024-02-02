defmodule PorscheConnEx.Struct.Vehicle do
  @moduledoc """
  Structure containing information about a vehicle attached to an API account.

  This is the structure returned by `PorscheConnEx.Client.vehicles/1`.

  ## Fields

  - `vin` (string) — the 17-character Vehicle Identification Number
  - `pcc?` (boolean) — (presumably?) whether the vehicle has the Porsche Car Connect service
  - `relationship` (string) — the user's relationship to the vehicle
    - only known value is "OWNER"
  - `model_description` (string) — the vehicle model description, e.g. "Taycan GTS"
  - `model_type` (string) — the internal code for the model, e.g. "Y1ADE1"
  - `model_year` (integer) — the vehicle model year
  - `exterior_color` (string) — the vehicle colour by name, e.g. "vulkangraumetallic/vulkangraumetallic"
  - `exterior_color_hex` (string) — the vehicle colour by its HTML RGB hex code
  - `spin_enabled?` (boolean) — unknown
  - `login_method` — (presumably?) how the vehicle logged in to the user's account
  - `ota_active?` — (presumably?) whether the vehicle is receiving over-the-air updates
  - `attributes` (map of `string => string`) — extra vehicle metadata
    - if the vehicle has a nickname set, this will appear as `"licenseplate" => nickname`
  - `pending_relationship_termination_at` (unknown) - nil for me, but likely a `DateTime`?
  """

  use PorscheConnEx.Struct

  # Only used internally for parsing.
  # Once parsed, will be converted into a map entry.
  defmodule Attribute do
    @moduledoc false
    use PorscheConnEx.Struct

    param do
      field(:name, :string, required: true)
      field(:value, :string, required: true)
    end

    def to_tuple(%__MODULE__{name: name, value: value}), do: {name, value}
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

  def load(data) do
    with {:ok, vehicle} <- super(data) do
      {:ok,
       %__MODULE__{
         vehicle
         | attributes: vehicle.attributes |> Map.new(&Attribute.to_tuple/1)
       }}
    end
  end
end
