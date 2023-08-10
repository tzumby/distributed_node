defmodule DistributedNode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    attach_telemetry()

    topologies = [
      partisan: [
        strategy: PartisanEC2.Strategy.Tags,
        connect: {:partisan_peer_service, :join, []},
        disconnect: {:partisan_peer_service, :leave, []},
        list_nodes: {:partisan, :nodes, []},
        config: [
          ip_type: :private
        ]
      ]
    ]

    children = [
      DistributedNode.ExampleServer,
      {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DistributedNode.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def attach_telemetry do
    :ok =
      :telemetry.attach(
        "log-response-handler",
        [:web, :request, :done],
        &LogResponseHandler.handle_event/4,
        nil
      )

    :ok =
      :telemetry.attach_many(
        "log-response-handler-span",
        [
          [:worker, :processing, :start],
          [:worker, :processing, :stop],
          [:worker, :processing, :exception]
        ],
        &LogResponseHandler.handle_event/4,
        nil
      )
  end
end
