defmodule PorscheConnEx.Struct.Emobility.ChargingProfile.ChargingOptions do
  use PorscheConnEx.Struct

  defmodule PreferredTime do
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
    field(:target_charge, :integer, key: "targetChargeLevel", required: true)
    field(:mode, :atom, required: true)

    field(:preferred_time_start, PreferredTime,
      key: "preferredChargingTimeStart",
      required: true
    )

    field(:preferred_time_end, PreferredTime,
      key: "preferredChargingTimeEnd",
      required: true
    )
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
end
