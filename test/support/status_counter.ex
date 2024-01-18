defmodule PorscheConnEx.Test.StatusCounter do
  use GenServer

  def start_link(opts) do
    {count, opts} = Keyword.pop!(opts, :count)
    GenServer.start_link(__MODULE__, count, opts)
  end

  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  @impl true
  def init(count) do
    {:ok, count}
  end

  @impl true
  def handle_call(:tick, _from, count) when count > 1, do: {:reply, :cont, count - 1}
  @impl true
  def handle_call(:tick, _from, 1), do: {:reply, :halt, 0}
  @impl true
  def handle_call(:tick, _from, 0), do: {:reply, :error, -1}

  @impl true
  def handle_call(:get, _from, count), do: {:reply, count, count}
end
