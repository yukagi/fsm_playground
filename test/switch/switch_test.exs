defmodule FsmPlayground.SwitchTest do
  use ExUnit.Case

  alias FsmPlayground.Switch

  setup do
    {:ok, _pid} = start_supervised(Switch, [])
    :ok
  end

  describe "get_state/0" do
    test "returns the current state of the switch" do
      assert Switch.get_state() == :off
    end
  end

  describe "flip/0" do
    test "toggles the switch between :on and :off" do
      assert Switch.get_state() == :off
      Switch.flip()
      assert Switch.get_state() == :on
      Switch.flip()
      assert Switch.get_state() == :off
    end
  end

  describe "get_count/0" do
    test "returns the current count of the switch" do
      # State is off, so count is 0
      assert Switch.get_count() == 0
      Switch.flip()
      # State is on, so count is incremented to 1
      assert Switch.get_count() == 1
      Switch.flip()
      # State is off, so count is still 1
      assert Switch.get_count() == 1
    end
  end
end
