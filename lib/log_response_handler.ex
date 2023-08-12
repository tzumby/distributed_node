defmodule LogResponseHandler do
  require Logger

  def handle_event(
        [:worker, :processing, :stop] = event,
        %{duration: duration} = _measurements,
        metadata,
        _config
      ) do
    #  Event: [:worker, :processing, :stop]
    #  Measurements: %{duration: 2571621, monotonic_time: -576460407581461477}
    #  Metadata: %{node: :"a@Razvans-MacBook-Pro-2", result: :hey_back, telemetry_span_context: #Reference<0.1191962707.377749506.193778>}

    name = event |> Enum.join("-")

    payload = %{
      name: name,
      unit: "native",
      value: duration,
      number_of_nodes: Map.get(metadata, :number_of_nodes),
      connected_nodes: Map.get(metadata, :connected_nodes),
      sent_by: Map.get(metadata, :sent_by),
      received_by: Map.get(metadata, :received_by),
      tags: metadata |> Map.delete(:telemetry_span_context),
      timestamp: NaiveDateTime.utc_now()
    }

    publish_telemetry_metric(payload)
  end

  def handle_event(_event, _measurements, _metadata, _config) do
    #  Event: [:worker, :processing, :start]
    #  Measurements: %{monotonic_time: -576460407584033098, system_time: 1691092298148313902}
    #  Metadata: %{node: :"a@Razvans-MacBook-Pro-2", telemetry_span_context: #Reference<0.1191962707.377749506.193778>}

    # Logger.info("Event: #{inspect(event)}")
    # Logger.info("Measurements: #{inspect(measurements)}")
    # Logger.info("Metadata: #{inspect(metadata)}")
  end

  def publish_telemetry_metric(payload) do
    url = Application.get_env(:distributed_node, :rabbitmq_url)

    {:ok, conn} =
      AMQP.Connection.open(
        url,
        ssl_options: [
          verify: :verify_none,
          server_name_indication: :disable
        ]
      )

    {:ok, channel} = AMQP.Channel.open(conn)

    exchange = "events"

    AMQP.Basic.publish(channel, exchange, "", :erlang.term_to_binary(payload))
  end
end
