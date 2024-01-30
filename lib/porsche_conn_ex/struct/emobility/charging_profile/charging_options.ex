defmodule PorscheConnEx.Struct.Emobility.ChargingProfile.ChargingOptions do
  @moduledoc """
  Structure containing desired charging behaviour for a particular profile.

  ## Fields

  - `minimum_charge` (integer) — charge immediately if below this charge percentage (0 to 100)
  - `mode` (atom) — determines how the profile decides when to charge
    - when set to `:smart`, the vehicle will negotiate the best charging time with the charger
    - when set to `:preferred_time`, the vehicle will charge between the assigned hours, when possible
  - `preferred_time_start` (`Time`) — the start of the preferred hours (each day)
  - `preferred_time_end` (`Time`) — the end of the preferred hours (each day)

  ## Charging behaviour

  When plugged in, if the vehicle charge is below `minimum_charge`, charging
  will begin immediately.  (This also occurs if `minimum_charge` is ever raised
  above the vehicle's current charge.)

  Once the minimum charge is reached, the vehicle will choose when to charge
  based on the preferred hours and the next upcoming
  [timer](`PorscheConnEx.Emobility.Timer`) that has `charge?` set to `true`.  The
  timer defines the charge target (battery percentage) and the point at which
  the car should have reached that target (time), while the preferred hours
  help define when the actual charging will occur.

  If the next timer occurs during the preferred hours, then the timer will
  execute normally — charging will start some time before the `depart_time`,
  based on how long the vehicle expects charging to take.

  If the next timer occurs outside of the preferred hours, then the vehicle
  will start charging some time before `preferred_time_end`, and attempt to
  reach `target_charge` by the time preferred hours end.

  If the vehicle is used after the end of preferred hours, but before a timer,
  and the vehicle no longer meets the requested `target_charge`, it's currently
  unknown whether the vehicle will "top up" outside of preferred hours, or just
  fail to meet the charge target.  More testing needed.
  """

  use PorscheConnEx.Struct

  defmodule PreferredTime do
    @moduledoc false
    @format "{h24}:{0m}"
    def load(str) do
      with {:ok, ndt} = Timex.parse(str, @format) do
        {:ok, NaiveDateTime.to_time(ndt)}
      end
    end

    def dump(%Time{} = time) do
      Timex.format(time, @format)
    end
  end

  param do
    field(:minimum_charge, :integer, key: "minimumChargeLevel", required: true)
    field(:mode, :atom, required: true)

    field(:preferred_time_start, PreferredTime,
      key: "preferredChargingTimeStart",
      required: true
    )

    field(:preferred_time_end, PreferredTime,
      key: "preferredChargingTimeEnd",
      required: true
    )

    # I'm leaving out "targetChargeLevel" because it's not exposed in the UI,
    # and it doesn't seem like it can be changed (it always resets back to
    # 100).
    #
    # field(:target_charge, :integer, key: "targetChargeLevel", required: true)
  end

  def load(params) when is_map(params) do
    smart = Map.get(params, "smartChargingEnabled")
    preferred = Map.get(params, "preferredChargingEnabled")

    mode =
      case {smart, preferred} do
        {true, false} -> :smart
        {false, true} -> :preferred_time
        {_, _} -> nil
      end

    params
    |> Map.put(:mode, mode)
    |> super()
  end

  def dump(%__MODULE__{mode: mode} = struct) do
    with {:ok, map} <- super(struct) do
      {:ok,
       map
       |> Map.delete("mode")
       |> Map.merge(%{
         "smartChargingEnabled" => mode == :smart,
         "preferredChargingEnabled" => mode == :preferred_time
       })}
    end
  end
end
