defmodule FsmPlaygroundTest do
  use ExUnit.Case
  doctest FsmPlayground

  test "greets the world" do
    assert FsmPlayground.hello() == :world
  end
end
