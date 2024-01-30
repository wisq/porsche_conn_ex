defmodule PorscheConnEx.Type.ReverseUtcDateTime do
  @moduledoc false
  use Parameter.Parametrizable

  @format "{0D}.{0M}.{YYYY} {h24}:{m}:{s}"

  @impl true
  def load(value) do
    with {:ok, %NaiveDateTime{} = ndt} <- Timex.parse(value, @format) do
      DateTime.from_naive(ndt, "Etc/UTC")
    end
  end
end
