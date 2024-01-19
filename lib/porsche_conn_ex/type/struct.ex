defmodule PorscheConnEx.Type.Struct do
  defmacro __using__(for: module) do
    quote do
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

  def load(module, item) do
    module.from_api(item)
  end

  def dump(_module, _item) do
    {:error, :not_implemented}
  end
end
