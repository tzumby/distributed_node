import Config

if config_env() == :prod do
  node_name =
    System.get_env("NODE_NAME") ||
      raise """
      NODE_NAME environment variable is not set.
      """

  rabbitmq_url =
    System.get_env("RABBITMQ_URL") ||
      raise """
      RABBITMQ_URL environment variable is not set.
      """

  config :distributed_node, :rabbitmq_url, rabbitmq_url

  config :partisan, :name, node_name |> String.to_atom()
end
