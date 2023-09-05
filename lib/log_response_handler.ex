defmodule LogResponseHandler do
  require Logger

  def handle_event(
        [:worker, :processing, :stop] = event,
        %{duration: duration} = _measurements,
        metadata,
        _config
      ) do
    name = event |> Enum.join("-")

    payload = %{
      name: name,
      unit: "native",
      value: duration,
      number_of_nodes: Map.get(metadata, :number_of_nodes) + 1,
      tags: metadata |> Map.delete(:telemetry_span_context),
      timestamp: NaiveDateTime.utc_now()
    }

    publish_telemetry_metric(payload)
  end

  def publish_telemetry_metric(payload) do
    url = Application.get_env(:distributed_node, :rabbitmq_url)

    {:ok, conn} = AMQP.Connection.open(url)

    {:ok, channel} = AMQP.Channel.open(conn)

    exchange = "events"

    AMQP.Basic.publish(channel, exchange, "", :erlang.term_to_binary(payload))
  end
end
