defmodule FsmPlayground.Switch do
  @moduledoc """
    This is a simple state machine that represents a light switch.
   It has two states:
   :on and :off
   It has two events:
   - :flip : toggles the switch between :on and :off. Also increments
       the count of how many times the switch has been flipped on.
   - :get_state : returns the current state of the switch
       without changing the state of the machine
   
          ┌────flip─────┐
          │             │
       ┌──▼───┐      ┌──┴───┐
       │      │      │      │
       │  On  │      │ Off  │
       │      │      │      │
       └───┬──┘      └───▲──┘
           │             │
           └────flip─────┘
   
"""

  # Default setup for GenStateMachine
  use GenStateMachine

  # Client API Functions; used to manipuate the state machine from the outside.
  def get_state do
    GenStateMachine.call(__MODULE__, :get_state)
  end

  def get_count do
    GenStateMachine.call(__MODULE__, :get_count)
  end

  def flip do
    GenStateMachine.cast(__MODULE__, :flip)
  end

  # GenStateMachine Callbacks; used to define the state machine without any options
   def start_link(_opts) do
     GenStateMachine.start_link(__MODULE__, {:off, [count: 0]}, name: __MODULE__)
   end

  # GenStateMachine Callbacks; used to define the state machine with options
  #  def start_link(_opts) do
  #    GenStateMachine.start_link(__MODULE__, {:on, [count: 5]}, name: __MODULE__)
  #  end

  def init({state, opts}) do
    count = Keyword.get(opts, :count, 0)
    {:ok, state, count}
  end

  # The way this works using this style of call back is:
  # handle_event(:cast, :trigger, from_state, data)
  def handle_event(:cast, :flip, :off, data) do
    IO.puts("Switch is now ON")
    {:next_state, :on, data + 1}
  end

  def handle_event(:cast, :flip, :on, data) do
    IO.puts("Switch is now OFF")
    {:next_state, :off, data}
  end

  def handle_event({:call, from}, :get_count, state, data) do
    {:next_state, state, data, [{:reply, from, data}]}
  end

  def handle_event({:call, from}, :get_state, state, data) do
    {:next_state, state, data, [{:reply, from, state}]}
  end
end
