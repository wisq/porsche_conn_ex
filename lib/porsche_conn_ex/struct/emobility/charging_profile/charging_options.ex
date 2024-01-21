defmodule PorscheConnEx.Struct.Emobility.ChargingProfile.ChargingOptions do
  use PorscheConnEx.Struct

  defmodule PreferredTime do
    def load(<<hours::binary-size(2), ":", minutes::binary-size(2)>> = str) do
      with {hours, ""} <- Integer.parse(hours),
           {minutes, ""} <- Integer.parse(minutes),
           {:ok, time} <- Time.new(hours, minutes, 0) do
        {:ok, time}
      else
        _ -> {:error, "Invalid time: #{inspect(str)}"}
      end
    end
  end

  param do
    field(:minimum, :integer, key: "minimumChargeLevel", required: true)
    field(:target, :integer, key: "targetChargeLevel", required: true)
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
