defmodule DistributedNodeTest do
  use ExUnit.Case
  doctest DistributedNode

  test "greets the world" do
    assert DistributedNode.hello() == :world
  end
end
