import Config

if config_env() == :prod do

  node_name =
    System.get_env("NODE_NAME") ||
      raise """
      NODE_NAME environment variable is not set.
      """

  config :partisan, :name, node_name |> String.to_atom()
end
