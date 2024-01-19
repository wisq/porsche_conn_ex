defmodule PorscheConnEx.Type.Struct do
  def struct(module) do
    ["PorscheConnEx", "Struct" | rest] = Module.split(module)

    type_module = ["PorscheConnEx", "Type", "Struct" | rest] |> Module.concat()

    unless is_compiled?(type_module) do
      quote do
        defmodule unquote(type_module) do
          use Parameter.Parametrizable

          @impl true
          def load(values) do
            PorscheConnEx.Type.Struct.load(unquote(module), values)
          end

          @impl true
          def validate(_value) do
            :ok
          end

          @impl true
          def dump(value) do
            PorscheConnEx.Type.Struct.dump(unquote(module), value)
          end
        end
      end
      |> Code.compile_quoted()
    end

    type_module
  end

  def list_of(module) do
    ["PorscheConnEx", "Struct" | rest] = Module.split(module)

    type_module =
      ["PorscheConnEx", "Type", "Struct", rest, "List"]
      |> List.flatten()
      |> Module.concat()

    unless is_compiled?(type_module) do
      quote do
        defmodule unquote(type_module) do
          use Parameter.Parametrizable

          @impl true
          def load(values) do
            PorscheConnEx.Type.Struct.load_list_of(unquote(module), values)
          end

          @impl true
          def validate(_value) do
            :ok
          end

          @impl true
          def dump(value) do
            PorscheConnEx.Type.Struct.dump_list_of(unquote(module), value)
          end
        end
      end
      |> Code.compile_quoted()
    end

    type_module
  end

  def map_of(module) do
    ["PorscheConnEx", "Struct" | rest] = Module.split(module)

    type_module =
      ["PorscheConnEx", "Type", "Struct", rest, "Map"]
      |> List.flatten()
      |> Module.concat()

    unless is_compiled?(type_module) do
      quote do
        defmodule unquote(type_module) do
          use Parameter.Parametrizable

          @impl true
          def load(values) do
            PorscheConnEx.Type.Struct.load_map_of(unquote(module), values)
          end

          @impl true
          def validate(_value) do
            :ok
          end

          @impl true
          def dump(value) do
            PorscheConnEx.Type.Struct.dump_map_of(unquote(module), value)
          end
        end
      end
      |> Code.compile_quoted()
    end

    type_module
  end

  def load(module, item) do
    module.from_api(item)
  end

  def dump(_module, _item) do
    {:error, :not_implemented}
  end

  def load_list_of(module, items) do
    items
    |> Enum.flat_map_reduce(:ok, fn item, :ok ->
      case module.from_api(item) do
        {:ok, struct} -> {[struct], :ok}
        {:error, _} = err -> {:halt, err}
      end
    end)
    |> then(fn
      {list, :ok} -> {:ok, list}
    end)
  end

  def dump_list_of(_module, _items) do
    {:error, :not_implemented}
  end

  def load_map_of(module, items) do
    items
    |> Enum.flat_map_reduce(:ok, fn {key, value}, :ok when is_binary(key) ->
      case module.from_api(value) do
        {:ok, struct} -> {[{key, struct}], :ok}
        {:error, _} = err -> {:halt, err}
      end
    end)
    |> then(fn
      {map, :ok} -> {:ok, Map.new(map)}
    end)
  end

  def dump_map_of(_module, _items) do
    {:error, :not_implemented}
  end

  defp is_compiled?(module) do
    function_exported?(module, :__info__, 1)
  end
end
