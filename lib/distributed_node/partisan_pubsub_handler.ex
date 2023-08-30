defmodule DistributedNode.PartisanPubSubHandler do
  use GenServer

  alias Phoenix.PubSub

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    PubSub.subscribe(DistributedNode.PubSub, "distributed_node:partisan_pubsub_test")

    {:ok, %{}}
  end

  def handle_info({:pubsub_broadcast, _}, state) do
    # local node broadcast, ignoring
    {:noreply, state}
  end

  def handle_info({:broadcast, {:pubsub_broadcast, uuid}}, state) do
    url = Application.get_env(:distributed_node, :rabbitmq_url)

    {:ok, active} = :partisan_hyparview_peer_service_manager.active()
    active = active |> Enum.map(fn {k, _v} -> k.name end)

    {:ok, passive} = :partisan_hyparview_peer_service_manager.passive()
    passive = passive |> Enum.map(fn {k, _v} -> k.name end)

    Logger.info(
      "patisan_node: #{inspect(:partisan.node())}. active: #{inspect(active)} passive: #{inspect(passive)}"
    )

    payload = %{
      type: "pubsub_receive",
      received_by: Node.self() |> Atom.to_string(),
      id: uuid,
      timestamp_received: NaiveDateTime.utc_now()
    }

    {:ok, conn} =
      AMQP.Connection.open(
        url,
        ssl_options: [verify: :verify_none]
      )

    {:ok, channel} = AMQP.Channel.open(conn)

    exchange = "events"

    AMQP.Basic.publish(channel, exchange, "", :erlang.term_to_binary(payload))

    AMQP.Connection.close(conn)

    {:noreply, state}
  end
end
