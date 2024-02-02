defmodule PorscheConnEx.Struct.Maintenance.Task.Description do
  @moduledoc """
  Structure containing descriptive information about a maintenance task.

  ## Fields

  - `short_name` (string) — the short name of the task
    - e.g. "TPMS battery (front left)" or "RDK-Batterie (vorne links)"
  - `long_name` (string) — the long name of the task
    - e.g. "Replace TPMS battery (front left)" or "Wechsel der RDK-Batterie (vorne links)"
  - `criticality` (integer) — seems to be a sentence describing whether maintenance is required?
    - e.g. "No maintenance is due at the moment." or "Zurzeit ist kein Service notwendig."
  - `notification` (unknown) — always `nil` in testing
    - Might be non-nil if maintenance is required?

  The strings in this structure are heavily influenced by the session locale (see `PorscheConnEx.Config`).
  """
  use PorscheConnEx.Struct

  param do
    field(:short_name, :string, key: "shortName", required: true)
    field(:long_name, :string, key: "longName", required: false)
    field(:criticality, :string, key: "criticalityText", required: true)
    field(:notification, :any, key: "notificationText", required: false)
  end
end
