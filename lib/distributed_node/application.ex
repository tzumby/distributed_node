defmodule DistributedNode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    attach_telemetry()

    start_distribution()

    topologies = [
      gossip: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "224.0.0.10",
	  secret: "somepassword"]]
    ]

    children = [
      DistributedNode.ExampleServer,
      {Phoenix.PubSub, name: DistributedNode.PubSub, adapter_name: Phoenix.PubSub.PG2},
      DistributedNode.PubSubHandler,
      {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DistributedNode.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_distribution do
    :application.set_env(:kernel, :net_ticker_spawn_options, [{:fullsweep_after, 0}])
    :application.set_env(:kernel, :inet_dist_listen_options, [
	{:high_watermark, 16777216},
        {:low_watermark, 14680064},
	{:nodelay, true},
	{:reuseaddr, true},
	{:debug, false},
	{:buffer, 5000000},
	{:active, false},
	{:backlog, 4096}
   ])

    :application.set_env(:kernel, :inet_dist_connect_options, [
	{:high_watermark, 16777216},
        {:low_watermark, 14680064},
	{:debug, false},
	{:nodelay, true},
	{:buffer, 5000000},
    ])


    :net_kernel.start(node_name(), %{name_domain: :longnames})
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

  def node_name do 
    Application.get_env(:distributed_node, :node_name, "app") |> String.trim() |> String.to_atom()  
  end 
end
