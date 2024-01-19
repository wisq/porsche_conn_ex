defmodule PorscheConnEx.Struct do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Parameter.Schema

      def from_api(params) do
        case Parameter.load(__MODULE__, params) do
          {:ok, fields} -> {:ok, struct!(__MODULE__, fields)}
          {:error, _} = err -> err
        end
      end

      if Keyword.get(opts, :writable, false) do
        def to_api(%__MODULE__{} = struct) do
          Parameter.dump(__MODULE__, struct)
        end
      end
    end
  end
end
