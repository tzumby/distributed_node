defmodule DistributedNode.Benchmark do
  alias DistributedNode.{Benchmark, ExampleServer}

  def start_benchmark(number_of_nodes) do
    Enum.each(0..40, fn _x ->
      target = Enum.random(Node.list())

      rpc(target, number_of_nodes)
      remote_cast(target, number_of_nodes)
      remote_call(target, number_of_nodes)
      remote_spawn(target, number_of_nodes)
    end)
  end

  def rpc(target, nodes) do
    initial_metadata = %{
      sent_by: Node.self() |> Atom.to_string(),
      type: :rpc,
      number_of_nodes: nodes,
      connected_nodes: number_of_nodes()
    }

    :telemetry.span([:worker, :processing], initial_metadata, fn ->
      result = :rpc.call(target, Benchmark, :get_remote_data_back, [self()])

      {result, Map.merge(initial_metadata, %{result: result})}
    end)
  end

  def remote_cast(target, nodes) do
    initial_metadata = %{
      sent_by: Node.self() |> Atom.to_string(),
      type: :cast,
      number_of_nodes: nodes,
      connected_nodes: number_of_nodes()
    }

    :telemetry.span([:worker, :processing], initial_metadata, fn ->
      GenServer.cast({ExampleServer, target}, {:remote_cast, self()})

      receive do
        message ->
          result = "received #{message}"
          {result, Map.merge(initial_metadata, %{result: result})}
      end
    end)
  end

  def remote_call(target, nodes) do
    initial_metadata = %{
      sent_by: Node.self() |> Atom.to_string(),
      type: :call,
      number_of_nodes: nodes,
      connected_nodes: number_of_nodes()
    }

    :telemetry.span([:worker, :processing], initial_metadata, fn ->
      result = GenServer.call({ExampleServer, target}, {:remote_call, "hello world!"})

      {result, Map.merge(initial_metadata, %{result: result})}
    end)
  end

  def remote_spawn(target, nodes) do
    initial_metadata = %{
      sent_by: Node.self() |> Atom.to_string(),
      type: :spawn,
      number_of_nodes: nodes,
      connected_nodes: number_of_nodes()
    }

    :telemetry.span([:worker, :processing], initial_metadata, fn ->
      Node.spawn(target, Benchmark, :get_remote_data_back, [self()])

      receive do
        message ->
          result = "received #{message}"
          {result, Map.merge(initial_metadata, %{result: result})}
      end
    end)
  end

  def get_remote_data_back(sender) when is_pid(sender) do
    send(sender, :hey_back)
  end

  defp number_of_nodes do
    Node.list() |> length()
  end
end
