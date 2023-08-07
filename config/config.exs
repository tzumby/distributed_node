import Config

config :ex_aws,
  debug_requests: false,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :distributed_node, :debug, false

config :distributed_node, DistributedNode.TelemetryPipeline,
  rabbitmq_url:
    "amqps://admin:87!KCDcMG9nL*pLD@b-69264c08-8410-49f7-81af-aeea3607b590.mq.us-east-2.amazonaws.com:5671"

config :partisan, :membership_strategy, :partisan_scamp_v2_membership_strategy
config :partisan, :peer_service_manager, :partisan_hyparview_peer_service_manager

import_config "#{config_env()}.exs"
