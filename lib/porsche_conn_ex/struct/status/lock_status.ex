defmodule PorscheConnEx.Struct.Status.LockStatus do
  @moduledoc """
  Structure describing the open/closed and locked/unlocked status of a vehicle door.

  ## Fields

  - `open?` (boolean) — whether the door is physically open
  - `locked?` (boolean) — whether the door is locked to prevent it opening

  Note that while the vehicle hood also uses this structure, it is always
  considered unlocked, and is not counted in the overall locked/unlocked state
  of the vehicle.
  """

  @enforce_keys [:open?, :locked?]
  defstruct(@enforce_keys)

  @type t :: %__MODULE__{
          open?: boolean,
          locked?: boolean
        }

  @doc false
  def load(term) do
    [open, locked] = String.split(term, "_")

    with {:ok, open} <- open_from_api(open),
         {:ok, locked} <- locked_from_api(locked) do
      {:ok, %__MODULE__{open?: open, locked?: locked}}
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
  alias PorscheConnEx.Struct.Status.LockStatus

  def inspect(%LockStatus{open?: open, locked?: locked}, _opts) do
    inner =
      [
        if(open, do: "open", else: "closed"),
        if(locked, do: "locked", else: "unlocked")
      ]
      |> Enum.join(",")

    "#PCX:LockStatus<#{inner}>"
  end
end
