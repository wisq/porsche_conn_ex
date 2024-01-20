defmodule PorscheConnEx.Struct.Maintenance do
  use PorscheConnEx.Struct

  defmodule TaskList do
    use PorscheConnEx.Type.StructList, of: PorscheConnEx.Struct.Maintenance.Task
  end

  defmodule ServiceAccess do
    def load(%{"access" => bool}) when is_boolean(bool), do: {:ok, bool}
    def load(v), do: {:error, "unknown ServiceAccess: #{inspect(v)}"}
  end

  param do
    field(:schedule, TaskList, key: "data", required: true)
    field(:service_access?, ServiceAccess, key: "serviceAccess", required: true)
  end
end
