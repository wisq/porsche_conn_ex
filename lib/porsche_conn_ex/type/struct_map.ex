defmodule PorscheConnEx.Type.StructMap do
  @moduledoc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @moduledoc false
      use Parameter.Parametrizable

      {module, opts} = Keyword.pop!(opts, :of)
      {allow_null, opts} = Keyword.pop(opts, :allow_null, false)

      unless Enum.empty?(opts) do
        raise "Unknown options: #{inspect(opts)}"
      end

      @impl true
      def load(values) do
        PorscheConnEx.Type.StructMap.load(unquote(module), values, unquote(allow_null))
      end

      @impl true
      def validate(_value) do
        :ok
      end

      @impl true
      def dump(value) do
        PorscheConnEx.Type.StructMap.dump(unquote(module), value, unquote(allow_null))
      end
    end
  end

  def load(module, items, allow_null) do
    items
    |> Enum.flat_map_reduce(:ok, fn
      {key, nil}, :ok when is_binary(key) ->
        if allow_null do
          {[{key, nil}], :ok}
        else
          {:halt, {:error, :null}}
        end

      {key, value}, :ok when is_binary(key) ->
        case module.load(value) do
          {:ok, struct} -> {[{key, struct}], :ok}
          {:error, _} = err -> {:halt, err}
        end
    end)
    |> then(fn
      {map, :ok} -> {:ok, Map.new(map)}
      {_, {:error, _} = err} -> err
    end)
  end

  def dump(_module, _items, _allow_null) do
    {:error, :not_implemented}
  end
end
