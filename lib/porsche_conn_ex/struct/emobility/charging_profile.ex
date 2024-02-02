defmodule PorscheConnEx.Struct.Emobility.ChargingProfile do
  alias PorscheConnEx.Docs
  alias __MODULE__, as: CP

  @moduledoc """
  Structure describing a vehicle charging profile.

  Charging profiles define basic charging parameters, such as charging targets,
  preferred charging hours, etc.  They can also be tied to a specific
  geographical location, such as a home or office, in which case they will
  automatically de/activate based on the vehicle's location.

  ## API calls

  - To create or update a charging profile, use `PorscheConnEx.Client.put_charging_profile/4`.
  - To delete a charging profile, use `PorscheConnEx.Client.delete_charging_profile/4`.

  ## Fields

  - `id` (integer) — the ID (slot number) of the charging profile
    - The default built-in profile is slot #4.
    - User-created profiles are in slots 5 through 7.
  - `name` (string) — the display name of the profile
    - The default profile is named "Allgemein" (German for "General"), regardless of [locale settings](`PorscheConnEx.Config`).
  - `enabled?` (boolean) — whether the charging profile is enabled or not
    - This **only** indicates whether the profile can be used, not whether it's currently selected.
  - `charging` (#{Docs.type(CP.ChargingOptions)}) — the desired charging behaviour while this profile is active
    - contains #{Docs.count_fields(CP.ChargingOptions)} sub-fields
  - `position` (#{Docs.type(CP.Position)} or `nil`) — the geographical location at which to activate the profile (if set)
    - contains #{Docs.count_fields(CP.Position)} sub-fields
  """
  use PorscheConnEx.Struct

  param do
    field(:id, :integer, key: "profileId", required: true)
    field(:name, :string, key: "profileName", required: true)
    field(:enabled?, :boolean, key: "profileActive", required: true)

    field(:charging, CP.ChargingOptions, key: "chargingOptions", required: true)
    field(:position, CP.Position)
  end

  @type id :: 4..7
  @type t :: %__MODULE__{
          id: id,
          name: binary,
          enabled?: boolean,
          charging: CP.ChargingOptions.t(),
          position: CP.Position.t()
        }

  # I'm not going to bother parsing these options, because
  #
  #   - they don't seem to be exposed in the car or app UI at all;
  #   - I'm not sure what they do, so I can't properly name them; and,
  #   - I don't even know whether it's safe to set them at all.
  #
  #    "profileOptions" : {
  #      "autoPlugUnlockEnabled" : false,
  #      "energyCostOptimisationEnabled" : false,
  #      "energyMixOptimisationEnabled" : false,
  #      "powerLimitationEnabled" : false,
  #      "timeBasedEnabled" : false,
  #      "usePrivateCurrentEnabled" : true
  #    },
  #    "timerActionList" : {
  #      "timerAction" : [ 1, 2, 3, 4, 5 ]
  #    }
end
