defmodule PorscheConnEx.Struct.Status.LockStatus do
  @enforce_keys [:open, :locked]
  defstruct(@enforce_keys)

  def load(term) do
    [open, locked] = String.split(term, "_")

    with {:ok, open} <- open_from_api(open),
         {:ok, locked} <- locked_from_api(locked) do
      {:ok, %__MODULE__{open: open, locked: locked}}
    else
      :error -> {:error, "invalid LockStatus: #{inspect(term)}"}
    end
  end

  defp open_from_api("OPEN"), do: {:ok, true}
  defp open_from_api("CLOSED"), do: {:ok, false}
  defp open_from_api(_), do: :error

  defp locked_from_api("LOCKED"), do: {:ok, true}
  defp locked_from_api("UNLOCKED"), do: {:ok, false}
  defp locked_from_api(_), do: :error
end

defimpl Inspect, for: PorscheConnEx.Struct.Status.LockStatus do
  def inspect(ls, _opts) do
    inner =
      [
        if(ls.open, do: "open", else: "closed"),
        if(ls.locked, do: "locked", else: "unlocked")
      ]
      |> Enum.join(",")

    "#PCX:LockStatus<#{inner}>"
  end
end
