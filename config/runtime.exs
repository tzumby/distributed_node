import Config

if config_env() == :prod do

  rabbitmq_url =
    System.get_env("RABBITMQ_URL") ||
      raise """
      RABBITMQ_URL environment variable is not set.
      """

  node_name = System.get_env("NODE_NAME") || "app"

  config :distributed_node, :rabbitmq_url, rabbitmq_url
  config :distributed_node, :node_name, node_name
end
