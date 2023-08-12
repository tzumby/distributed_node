import Config

if config_env() == :prod do

  rabbitmq_url =
    System.get_env("RABBITMQ_URL") ||
      raise """
      RABBITMQ_URL environment variable is not set.
      """

  config :distributed_node, :rabbitmq_url, rabbitmq_url
end
