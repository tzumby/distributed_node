import Config

config :ex_aws,
  debug_requests: false,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :partisan, :membership_strategy, :partisan_scamp_v2_membership_strategy
config :partisan, :peer_service_manager, :partisan_hyparview_peer_service_manager
# config :partisan, :peer_port, 41234
config :partisan, :hyparview, random_promotion: false, shuffle_interval: 100_000
# config :partisan, :peer_port, 31234

config :appsignal, :config, otp_app: :distributed_node

import_config "#{config_env()}.exs"
