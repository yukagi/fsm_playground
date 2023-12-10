defmodule FsmPlayground.Lockbox do
  @moduledoc """
  This is a state machine that represents a lockbox.

  It has two states:
  :locked and :unlocked

  It has three events:
  - :unlock : unlocks the lockbox if the correct code is provided
    After the timeout expires, the lockbox automatically locks itself.
    This is done via the :state_timeout event.
  - :change_passcode : changes the passcode to a new value
  - :get_state : returns the current state of the lockbox
           ┌─────────┐
    ┌──────► locked  ◄────────┬───────────────┐
    │      └────┬────┘        │               │
    │           │             │               │
    │           │          incorrect code     │
    │      ┌────┴────┐        │               │
    │      │ *unlock ├────────┘               │
    │      └────┬────┘                        │
    │           │                             │
    │      correct code                       │
    │           │                             │
    │           │                             │
    │           │                             │
    │           │                             │
    │      ┌────▼─────┐                       │
    │      │ unlocked ├──────^timeout─────────┘
    │      └────┬─────┘       expires
    │           │
    │           │
    │      ┌────┴────┐         *change_passcode: updates data, maintains state
    │      │ *unlock │
    │      └────┬────┘
    │           │
    └───────────┘
"""

  use GenStateMachine

  # Client API Functions; used to manipuate the state machine from the outside.
  def get_state do
    GenStateMachine.call(__MODULE__, :get_state)
  end

  def unlock(access_code) do
    GenStateMachine.call(__MODULE__, {:unlock, access_code})
  end

  def change_passcode(new_access_code) do
    GenStateMachine.cast(__MODULE__, {:change_passcode, new_access_code})
  end

  def start_link(_opts) do
    # Start the lockbox in the locked state
    GenStateMachine.start_link(__MODULE__, {:locked, [access_code: "2525"]}, name: __MODULE__)
  end

  def init({state, opts}) do
    {:ok, state, opts}
  end

  def handle_event({:call, from}, :get_state, state, data) do
    {:next_state, state, data, [{:reply, from, state}]}
  end

  def handle_event({:call, from}, {:unlock, entry_code}, :locked, data) do
    if entry_code == Keyword.get(data, :access_code) do
      # Here is where I'm going to want to start a timer.
      # And revert back to locked after the time expires.
      {:next_state, :unlocked, data, [{:state_timeout, 5_000, :lock}, {:reply, from, :ok}]}
    else
      {:keep_state_and_data, [{:reply, from, :error}]}
    end
  end

  # handle the event if someone tries to unlock an unlocked lock.
  def handle_event({:call, from}, {:unlock, entry_code}, :unlocked, data) do
    if entry_code == Keyword.get(data, :access_code) do
      {:next_state, :locked, data, [{:reply, from, :relocked}]}
    else
      {:next_state, :locked, data, [{:reply, from, :invalid_code}]}
    end
  end

  # this callback is called when the state_timeout expires
  # :lock is the trigger that is passed in to the state_timeout,
  # :unlocked is the state that we are in when the timeout expires
  def handle_event(:state_timeout, :lock, :unlocked, data) do
    IO.puts("Automatically locking the lockbox")
    {:next_state, :locked, data}
  end

  def handle_event(:cast, {:change_passcode, new_access_code}, _state, data) do
    {:keep_state, Keyword.put(data, :access_code, new_access_code)}
  end
end
