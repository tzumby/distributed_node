defmodule DistributedNode.Benchmark do
  alias DistributedNode.{Benchmark, ExampleServer}

  def broadcast(number_of_nodes) do
    url = Application.get_env(:distributed_node, :rabbitmq_url)

    uuid = UUID.uuid4()

    payload = %{
      type: "pubsub_send",
      id: uuid,
      timestamp_sent: NaiveDateTime.utc_now(),
      sent_by: Node.self() |> Atom.to_string(),
      number_of_nodes: number_of_nodes,
      connected_nodes: length(Node.list()) + 1
    }

    {:ok, conn} =
      AMQP.Connection.open(
        url,
        ssl_options: [verify: :verify_none]
      )

    {:ok, channel} = AMQP.Channel.open(conn)

    exchange = "events"

    AMQP.Basic.publish(channel, exchange, "", :erlang.term_to_binary(payload))

    Phoenix.PubSub.broadcast(
      DistributedNode.PubSub,
      "distributed_node:partisan_pubsub_test",
      {:pubsub_broadcast, uuid}
    )

    AMQP.Connection.close(conn)
  end

  def start_benchmark do
    Enum.each(0..40, fn _x ->
      target = Enum.random(Node.list())

      rpc(target)
      remote_cast(target)
      remote_call(target)
      remote_spawn(target)
    end)
  end

  def rpc(target) do
    initial_metadata = %{node: Node.self(), type: :rpc, number_of_nodes: number_of_nodes()}

    :telemetry.span([:worker, :processing], initial_metadata, fn ->
      result = :rpc.call(target, Benchmark, :get_remote_data_back, [self()])

      {result, Map.merge(initial_metadata, %{result: result})}
    end)
  end

  def remote_cast(target) do
    initial_metadata = %{node: Node.self(), type: :cast, number_of_nodes: number_of_nodes()}

    :telemetry.span([:worker, :processing], initial_metadata, fn ->
      GenServer.cast({ExampleServer, target}, {:remote_cast, self()})

      receive do
        message ->
          result = "received #{message}"
          {result, Map.merge(initial_metadata, %{result: result})}
      end
    end)
  end

  def remote_call(target) do
    initial_metadata = %{node: Node.self(), type: :call, number_of_nodes: number_of_nodes()}

    :telemetry.span([:worker, :processing], initial_metadata, fn ->
      result = GenServer.call({ExampleServer, target}, {:remote_call, "hello world!"})

      {result, Map.merge(initial_metadata, %{result: result})}
    end)
  end

  def remote_spawn(target) do
    initial_metadata = %{node: Node.self(), type: :spawn, number_of_nodes: number_of_nodes()}

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
