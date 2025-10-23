defmodule OrqTest do
  use ExUnit.Case
  doctest Orq

  test "greets the world" do
    assert Orq.hello() == :world
  end
end
