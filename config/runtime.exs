import Config

if config_env() == :prod do
  node_name =
    System.get_env("NODE_NAME") |> String.to_atom() ||
      raise """
      NODE_NAME environment variable is not set.
      """

  node_port =
    System.get_env("NODE_PORT") |> String.to_integer() ||
      raise """
      NODE_PORT environment variable is not set.
      """

  config :partisan, :peer_port, node_port
  config :partisan, :name, node_name
end
