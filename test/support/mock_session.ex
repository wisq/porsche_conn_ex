defmodule PorscheConnEx.Test.MockSession do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def count(pid) do
    GenServer.call(pid, :count)
  end

  @impl true
  def init(nil) do
    {:ok, 0}
  end

  @impl true
  def handle_call(:headers, _from, count) do
    {:reply,
     %{
       "Authorization" => "Bearer mock",
       "origin" => "https://my.porsche.com",
       "apikey" => "mock",
       "x-vrs-url-country" => "de",
       "x-vrs-url-language" => "de/de_DE"
     }, count + 1}
  end

  @impl true
  def handle_call(:count, _from, count) do
    {:reply, count, count}
  end
end
