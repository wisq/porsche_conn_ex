defmodule PorscheConnEx.Struct do
  @moduledoc false

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Parameter.Schema
      import Parameter.Enum, except: [enum: 2]
      import PorscheConnEx.Struct.Enum

      @doc false
      def load(params) do
        case Parameter.load(__MODULE__, params) do
          {:ok, fields} -> {:ok, struct!(__MODULE__, fields)}
          {:error, _} = err -> err
        end
      end

      @doc false
      def dump(struct) do
        Parameter.dump(__MODULE__, struct)
      end

      defoverridable load: 1, dump: 1
    end
  end

  defmodule Enum do
    @moduledoc false

    defmacro enum(module, block) do
      quote do
        Parameter.Enum.enum unquote(module) do
          @moduledoc false
          unquote(block)
        end

        alias __MODULE__.unquote(module)
      end
    end
  end
end
