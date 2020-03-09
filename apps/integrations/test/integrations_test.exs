defmodule IntegrationsTest do
  use ExUnit.Case
  doctest Integrations

  test "greets the world" do
    assert Integrations.hello() == :world
  end
end
