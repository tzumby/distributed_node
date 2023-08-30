import Config

config :ex_aws,
  debug_requests: false,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :partisan, :membership_strategy, :partisan_scamp_v2_membership_strategy
config :partisan, :channels, [{:pubsub, %{parallelism: 10}}]
config :partisan, :peer_service_manager, :partisan_hyparview_peer_service_manager
config :partisan, :peer_port, 41234

config :partisan, :hyparview,
  active_max_size: 40,
  active_rwl: 40,
  passive_rwl: 20,
  active_min_size: 20,
  random_promotion: false,
  shuffle_interval: 1000

config :logger,
  # or other Logger level
  level: :debug,
  backends: [LogflareLogger.HttpBackend]

config :logflare_logger_backend,
  # https://api.logflare.app is configured by default and you can set your own url
  url: "https://api.logflare.app",
  # Default LogflareLogger level is :info. Note that log messages are filtered by the :logger application first
  level: :info,
  # your Logflare API key, found on your dashboard
  api_key: "yCv6vMZlNZAg",
  # the Logflare source UUID, found  on your Logflare dashboard
  source_id: "3c10072a-5c73-4c16-83e8-e84c61cb787e",
  # minimum time in ms before a log batch is sent
  flush_interval: 1_000,
  # maximum number of events before a log batch is sent
  max_batch_size: 50,
  # optionally you can drop keys if they exist with `metadata: [drop: [:list, :keys, :to, :drop]]`
  metadata: :all

import_config "#{config_env()}.exs"
