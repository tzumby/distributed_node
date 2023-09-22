defmodule DistributedNode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    attach_telemetry()

    # start_distribution()

    topologies = [
      example: [
        strategy: ClusterEC2.Strategy.Tags,
        config: [
          ec2_tagname: "Cluster",
          ip_type: :private_dns
        ]
      ]
    ]

    children = [
      DistributedNode.ExampleServer,
      {Phoenix.PubSub, name: DistributedNode.PubSub, adapter_name: Phoenix.PubSub.PG2},
      DistributedNode.PubSubHandler
      # {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DistributedNode.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_distribution do
    :net_kernel.start(:app, %{name_domain: :longnames})
  end

  def attach_telemetry do
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
