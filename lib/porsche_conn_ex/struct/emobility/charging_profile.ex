defmodule PorscheConnEx.Struct.Emobility.ChargingProfile do
  use PorscheConnEx.Struct

  alias __MODULE__, as: CP

  param do
    field(:id, :integer, key: "profileId", required: true)
    field(:name, :string, key: "profileName", required: true)
    field(:active, :boolean, key: "profileActive", required: true)

    field(:charging, CP.ChargingOptions, key: "chargingOptions", required: true)
    field(:position, CP.Position)
  end

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
