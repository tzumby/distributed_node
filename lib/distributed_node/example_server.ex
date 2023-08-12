defmodule DistributedNode.ExampleServer do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{}}
  end

  def handle_cast({:remote_cast, sender}, state) do
    send(sender, {:hey_back, Node.self()})

    {:noreply, state}
  end

  def handle_call({:remote_call, sender}, _from, state) do
    {:reply, "received #{sender}", state}
  end
end
