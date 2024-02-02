defmodule PorscheConnEx.Struct.Unit.Temperature do
  @moduledoc """
  Structure representing temperature.

  ## Fields

  - `celsius` (float) — temperature in degrees Celsius (°C) with one decimal precision
  - `decikelvin` (integer) — temperature in tenths of degrees Kelvin (dK)

  The API only provides `decikelvin`, but this library provides a `celsius`
  value for convenience, since conversion is simple and precise.  Note that
  Porsche considers 0°C to be equivalent to 273 K, rather than the more
  accurate 273.15 K.

  Decikelvin is reportedly a common integer unit for industrial
  sensors, which is likely why Porsche uses this unit internally.
  """

  @enforce_keys [:celsius, :decikelvin]
  defstruct(@enforce_keys)

  @type t :: %__MODULE__{
          celsius: float,
          decikelvin: integer
        }

  # Yes, this should technically be 273.15 K, but Porsche seems to use 273K directly.
  @zero_celsius 2730

  @doc false
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
