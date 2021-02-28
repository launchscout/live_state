defmodule LiveStateTest do
  use ExUnit.Case
  doctest LiveState

  test "greets the world" do
    assert LiveState.hello() == :world
  end
end
