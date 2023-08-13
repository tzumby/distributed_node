import Config

config :ex_aws,
  debug_requests: false,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :distributed_node, :debug, false

config :appsignal, :config, otp_app: :distributed_node

config :distributed_node,
       :rabbitmq_url,
       "amqps://admin:87!KCDcMG9nL*pLD@b-69264c08-8410-49f7-81af-aeea3607b590.mq.us-east-2.amazonaws.com:5671"

import_config "#{config_env()}.exs"
