defmodule PorscheConnEx.Struct.Maintenance do
  alias PorscheConnEx.Docs
  alias PorscheConnEx.Struct.Maintenance.Task

  @moduledoc """
  Structure containing information about upcoming maintenance tasks.

  This is the structure returned by `PorscheConnEx.Client.maintenance/2`.

  ## Fields

  - `schedule` (list of #{Docs.type(Task)}) — a list of upcoming maintenance tasks
  - `service_access?` (boolean) — unknown

  Note that this structure is the least understood at the moment, since it
  changes very slowly and is not easily probed or tested.  As such, you will
  currently find a lot of "unknown" labels in the nested maintenance sub-structures.
  """

  use PorscheConnEx.Struct

  defmodule TaskList do
    use PorscheConnEx.Type.StructList, of: PorscheConnEx.Struct.Maintenance.Task
  end

  defmodule ServiceAccess do
    @moduledoc false
    def load(%{"access" => bool}) when is_boolean(bool), do: {:ok, bool}
    def load(v), do: {:error, "unknown ServiceAccess: #{inspect(v)}"}
  end

  param do
    field(:schedule, TaskList, key: "data", required: true)
    field(:service_access?, ServiceAccess, key: "serviceAccess", required: true)
  end

  @type t :: %__MODULE__{
          schedule: [Task.t()],
          service_access?: boolean
        }
end
