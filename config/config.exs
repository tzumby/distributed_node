import Config

config :ex_aws,
  debug_requests: false,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :partisan, :membership_strategy, :partisan_scamp_v2_membership_strategy
config :partisan, :peer_service_manager, :partisan_hyparview_peer_service_manager
config :partisan, :peer_port, 41234

config :partisan, :hyparview,
  # active_max_size: 10,
  # active_rwl: 10,
  # passive_rwl: 5,
  # active_min_size: 5,
  random_promotion: false,
  shuffle_interval: 1000

import_config "#{config_env()}.exs"
