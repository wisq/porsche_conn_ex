defmodule PorscheConnEx.Test.ClientCase do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use ExUnit.Case, opts |> Keyword.put_new(:async, true)

      setup do
        bypass = Bypass.open()

        {:ok, session} =
          PorscheConnEx.Test.MockSession.start_link(
            config: PorscheConnEx.Test.DataFactory.config(bypass)
          )

        {:ok, bypass: bypass, session: session}
      end
    end
  end
end
