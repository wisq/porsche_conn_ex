defmodule PorscheConnEx.Struct.Emobility.ChargingProfileMap do
  alias PorscheConnEx.Struct.Emobility.ChargingProfile

  def load(list) when is_list(list) do
    list
    |> Enum.flat_map_reduce(:ok, fn params, :ok ->
      case ChargingProfile.load(params) do
        {:ok, profile} -> {[profile], :ok}
        {:error, _} = err -> {:halt, err}
      end
    end)
    |> then(fn
      {list, :ok} -> {:ok, list |> Map.new(fn p -> {p.id, p} end)}
      {_, {:error, _} = err} -> err
    end)
  end
end
