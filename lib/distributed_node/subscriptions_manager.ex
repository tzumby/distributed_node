defmodule DistributedNode.SubscriptionsManager do
  def subscribe(topic) do
    Registry.register(Registry.PubSub, topic, [])
  end

  def subscriptions do
    Registry.keys(Registry.PubSub, self())
  end
end
