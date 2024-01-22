defmodule PorscheConnEx.Struct.Emobility do
  use PorscheConnEx.Struct

  alias __MODULE__, as: E

  defmodule TimerList do
    use PorscheConnEx.Type.StructList, of: E.Timer
  end

  param do
    field(:charging, E.ChargeStatus, key: "batteryChargeStatus", required: true)
    field(:direct_charge, E.DirectCharge, key: "directCharge", required: true)
    field(:direct_climate, E.DirectClimate, key: "directClimatisation", required: true)
    field(:timers, TimerList, required: true)
    field(:current_charging_profile_id, :integer, required: true)
    field(:charging_profiles, E.ChargingProfileMap, required: true)
  end

  # I'm choosing to flatten this a bit, since the sight of
  # `emobility.charging_profiles.profiles` offends me.
  def load(params) when is_map(params) do
    with {:ok, block} <- Map.fetch(params, "chargingProfiles"),
         {:ok, current_id} <- Map.fetch(block, "currentProfileId"),
         {:ok, profiles} <- Map.fetch(block, "profiles") do
      params
      |> Map.delete("chargingProfiles")
      |> Map.put("current_charging_profile_id", current_id)
      |> Map.put("charging_profiles", profiles)
      |> super()
    end
  end
end
