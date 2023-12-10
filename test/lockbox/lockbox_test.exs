defmodule FsmPlayground.LockboxTest do
  use ExUnit.Case

  alias FsmPlayground.Lockbox

  setup do
    {:ok, _pid} = start_supervised(Lockbox, [])
    :ok
  end

  describe "get_state/0" do
    test "returns the current state of the lockbox" do
      assert Lockbox.get_state() == :locked
    end
  end

  describe "unlock/1" do
    test "unlocks the lockbox if the correct code is provided" do
      assert Lockbox.get_state() == :locked
      assert Lockbox.unlock("2525") == :ok
      assert Lockbox.get_state() == :unlocked
    end

    test "does not unlock the lockbox if the incorrect code is provided" do
      assert Lockbox.get_state() == :locked
      assert Lockbox.unlock("1234") == :error
      assert Lockbox.get_state() == :locked
    end
  end

  describe "change_passcode/1" do
    test "changes the passcode to a new value" do
      assert Lockbox.get_state() == :locked
      assert Lockbox.unlock("2525") == :ok
      assert Lockbox.get_state() == :unlocked
      assert Lockbox.change_passcode("1234") == :ok
      assert Lockbox.get_state() == :unlocked
      assert Lockbox.unlock("1234") == :relocked
      assert Lockbox.get_state() == :locked
    end
  end

  describe "timeout" do
    test "automatically locks the lockbox after the timeout expires" do
      assert Lockbox.get_state() == :locked
      assert Lockbox.unlock("2525") == :ok
      assert Lockbox.get_state() == :unlocked
      :timer.sleep(6_000)
      assert Lockbox.get_state() == :locked
    end
  end
end
