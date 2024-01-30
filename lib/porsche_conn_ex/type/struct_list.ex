defmodule PorscheConnEx.Type.StructList do
  @moduledoc false
  defmacro __using__(of: module) do
    quote do
      @moduledoc false
      use Parameter.Parametrizable

      @impl true
      def load(values) do
        PorscheConnEx.Type.StructList.load(unquote(module), values)
      end

      @impl true
      def validate(_value) do
        :ok
      end

      @impl true
      def dump(value) do
        PorscheConnEx.Type.StructList.dump(unquote(module), value)
      end
    end
  end

  def load(module, items) do
    items
    |> Enum.flat_map_reduce(:ok, fn item, :ok ->
      case module.load(item) do
        {:ok, struct} -> {[struct], :ok}
        {:error, _} = err -> {:halt, err}
      end
    end)
    |> then(fn
      {list, :ok} -> {:ok, list}
      {_, {:error, _} = err} -> err
    end)
  end

  def dump(_module, _items) do
    {:error, :not_implemented}
  end
end
