defmodule PorscheConnEx.Struct.Unit.Temperature do
  @enforce_keys [:celsius, :decikelvin]
  defstruct(@enforce_keys)

  # Yes, this should technically be 273.15 K, but Porsche seems to use 273K directly.
  @zero_celsius 2730

  def load(decikelvin) when is_integer(decikelvin) do
    {:ok,
     %__MODULE__{
       decikelvin: decikelvin,
       celsius: dk_to_c(decikelvin)
     }}
  end

  def load(str) when is_binary(str) do
    case Integer.parse(str) do
      {n, ""} -> load(n)
      _ -> {:error, "not an integer: #{inspect(str)}"}
    end
  end

  def load(other), do: {:error, "not an integer or string: #{inspect(other)}"}

  defp dk_to_c(dk) do
    (dk - @zero_celsius) / 10.0
  end
end

defimpl Inspect, for: PorscheConnEx.Struct.Emobility.Temperature do
  def inspect(dist, _opts) do
    "#PCX:Temperature<#{inspect(dist.celsius)}°C / #{inspect(dist.decikelvin)} dK>"
  end
end
