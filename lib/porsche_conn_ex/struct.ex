defmodule PorscheConnEx.Struct do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Parameter.Schema

      def load(params) do
        case Parameter.load(__MODULE__, params) do
          {:ok, fields} -> {:ok, struct!(__MODULE__, fields)}
          {:error, _} = err -> err
        end
      end

      def dump(struct) do
        Parameter.dump(__MODULE__, struct)
      end

      defoverridable load: 1, dump: 1
    end
  end
end
