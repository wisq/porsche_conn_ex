defmodule PorscheConnEx.Struct.Emobility.DirectCharge do
  @moduledoc """
  Structure containing information about the "Direct Charge" setting of a
  particular vehicle.

  ## Fields

  - `disabled?` (boolean) — whether direct charging is disabled
    - The reasons this feature might be disabled (or disallowed?) are unknown.
  - `active?` (boolean) — whether direct charging is currently active
    - This indicates whether the "Direct Charge" setting has been activated by
      the user, and not necessarily whether the vehicle is actually charging.
  """

  use PorscheConnEx.Struct
  alias PorscheConnEx.Docs

  @doc false
  def field_docs, do: @moduledoc |> Docs.section("Fields")

  param do
    field(:disabled?, :boolean, key: "disabled", required: true)
    field(:active?, :boolean, key: "isActive", required: true)
  end
end
