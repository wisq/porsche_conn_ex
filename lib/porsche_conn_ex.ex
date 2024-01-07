defmodule PorscheConnEx do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      PorscheConnEx.CookieJar
    ]

    opts = [strategy: :one_for_one, name: PorscheConnEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
