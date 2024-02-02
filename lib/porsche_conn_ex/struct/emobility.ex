defmodule PorscheConnEx.Struct.Emobility do
  use PorscheConnEx.Struct

  alias PorscheConnEx.Docs
  alias __MODULE__, as: E

  @moduledoc """
  Structure containing information about the electric charging status and
  behaviour of a particular vehicle.

  This is the structure returned by `PorscheConnEx.Client.emobility/3`.

  Note that there is some overlap between this structure, `PorscheConnEx.Struct.Status`, and `PorscheConnEx.Struct.Overview`.

  ## Fields

  - `charging` (#{Docs.type(E.ChargeStatus)}) — information about the vehicle's charging status
    - contains #{Docs.count_fields(E.ChargeStatus)} sub-fields
  - `direct_charge` (#{Docs.type(E.DirectCharge)}) — info about the vehicle's "Direct Charge" setting
    - contains #{Docs.count_fields(E.DirectCharge)} sub-fields
  - `direct_climate` (#{Docs.type(E.DirectClimate)}) — info about the vehicle's pre-heat/cool setting
    - contains #{Docs.count_fields(E.DirectClimate)} sub-fields
  - `timers` (list of #{Docs.type(E.Timer)}s) — all charging/climatisation timers (user-created)
  - `charging_profiles` (list of #{Docs.type(E.ChargingProfile)}s) — all charging profiles (built-in and user-created)
  - `current_charging_profile` (#{Docs.type(E.ChargingProfile)}) — the currently active charging profile

  For a list of sub-fields, see the relevant module documentation.
  """

  defmodule TimerList do
    use PorscheConnEx.Type.StructList, of: E.Timer
  end

  defmodule ChargingProfileList do
    use PorscheConnEx.Type.StructList, of: E.ChargingProfile
  end

  param do
    field(:charging, E.ChargeStatus, key: "batteryChargeStatus", required: true)
    field(:direct_charge, E.DirectCharge, key: "directCharge", required: true)
    field(:direct_climate, E.DirectClimate, key: "directClimatisation", required: true)
    field(:timers, TimerList, required: true)
    field(:charging_profiles, ChargingProfileList, required: true)
    field(:current_charging_profile, E.ChargingProfile, virtual: true)
  end

  @type t :: %__MODULE__{
          charging: E.ChargeStatus.t(),
          direct_charge: E.DirectCharge.t(),
          direct_climate: E.DirectClimate.t(),
          timers: [E.Timer.t()],
          charging_profiles: [E.ChargingProfile.t()],
          current_charging_profile: E.ChargingProfile.t()
        }

  # I'm choosing to flatten this a bit, since the sight of
  # `emobility.charging_profiles.profiles` offends me.
  def load(params) when is_map(params) do
    with {:ok, block} <- Map.fetch(params, "chargingProfiles"),
         {:ok, current_id} <- Map.fetch(block, "currentProfileId"),
         {:ok, profiles} <- Map.fetch(block, "profiles") do
      params =
        params
        |> Map.delete("chargingProfiles")
        |> Map.put("charging_profiles", profiles)

      with {:ok, emob} <- super(params) do
        current_profile = emob.charging_profiles |> Enum.find(&(&1.id == current_id))
        {:ok, %__MODULE__{emob | current_charging_profile: current_profile}}
      end
    end
  end
end
