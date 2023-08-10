defmodule DistributedNode.MixProject do
  use Mix.Project

  def project do
    [
      app: :distributed_node,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        distributed_node: [
          include_executables_for: [:unix],
          include_erts: true,
          cookie: 'supers3cr3t',
          steps: [:assemble, :tar],
          applications: [
            runtime_tools: :permanent
          ]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :lasp_pg],
      mod: {DistributedNode.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, path: "../libcluster"},
      {:telemetry, "~> 1.2"},
      {:amqp, "~> 3.3"},
      {:partisan, git: "https://github.com/lasp-lang/partisan.git", override: true},
      {:partisan_ec2_tags_strategy, path: "../partisan_ec2_tags_strategy/"},
      {:lasp_pg, git: "https://github.com/lasp-lang/lasp_pg.git"},
      {:appsignal, "~> 2.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
