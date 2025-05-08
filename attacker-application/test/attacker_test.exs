defmodule AttackerTest do
  use ExUnit.Case
  doctest Attacker

  test "greets the world" do
    assert Attacker.hello() == :world
  end
end
