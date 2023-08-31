import Config

to_boolean = fn
  true -> true
  "true" -> true
  "false" -> false
  false -> false
  1 -> true
  "1" -> true
  _else -> false
end

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

  active_max_size = System.get_env("ACTIVE_MAX_SIZE") || "100"
  active_rwl = System.get_env("ACTIVE_RWL") || "20"
  passive_rwl = System.get_env("PASSIVE_RWL") || "10"
  active_min_size = System.get_env("ACTIVE_MIN_SIZE") || "50"
  random_promotion = System.get_env("RANDOM_PROMOTION") || "false"
  shuffle_interval = System.get_env("SHUFFLE_INTERVAL") || "1000"

  peer_port = System.get_env("PEER_PORT") || "41234"

  membership_strategy =
    System.get_env("MEMBERSHIP_STRATEGY") || "partisan_scamp_v2_membership_strategy"

  peer_service_manager =
    System.get_env("PEER_SERVICE_MANAGER") || "partisan_hyparview_peer_service_manager"

  config :distributed_node, :rabbitmq_url, rabbitmq_url

  config :partisan, :name, node_name |> String.to_atom()

  config :partisan, :hyparview,
    active_max_size: active_max_size |> String.to_integer(),
    active_rwl: active_rwl |> String.to_integer(),
    passive_rwl: passive_rwl |> String.to_integer(),
    active_min_size: active_min_size |> String.to_integer(),
    random_promotion: random_promotion |> to_boolean.(),
    shuffle_interval: shuffle_interval |> String.to_integer()

  config :partisan, :peer_port, String.to_integer(peer_port)

  config :partisan, :peer_service_manager, String.to_atom(peer_service_manager)
  config :partisan, :membership_strategy, String.to_atom(membership_strategy)
end
