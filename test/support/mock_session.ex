defmodule PorscheConnEx.Test.MockSession do
  use GenServer

  alias PorscheConnEx.Config
  alias PorscheConnEx.Session.RequestData

  def start_link(opts) do
    {%Config{} = config, opts} = Keyword.pop!(opts, :config)
    GenServer.start_link(__MODULE__, config, opts)
  end

  def count(pid) do
    GenServer.call(pid, :count)
  end

  @impl true
  def init(%Config{} = config) do
    {:ok, {config, 0}}
  end

  @impl true
  def handle_call(:request_data, _from, {config, count}) do
    {:reply,
     %RequestData{
       config: config,
       headers: %{
         "Authorization" => "Bearer mock",
         "origin" => "https://my.porsche.com",
         "apikey" => "mock",
         "x-vrs-url-country" => "de",
         "x-vrs-url-language" => "de/de_DE"
       }
     }, {config, count + 1}}
  end

  @impl true
  def handle_call(:count, _from, {_config, count} = state) do
    {:reply, count, state}
  end
end
