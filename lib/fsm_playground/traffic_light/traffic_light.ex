defmodule FsmPlayground.TrafficLight do
  @moduledoc """
  # (enter, OldState, State, Data)
  """

  use GenStateMachine, callback_mode: [:handle_event_function, :state_enter]

  # Client API Functions; used to manipuate the state machine from the outside.
  def get_state do
    GenStateMachine.call(__MODULE__, :get_state)
  end

  def start_link(_opts) do
    GenStateMachine.start_link(__MODULE__, {:red, []}, name: __MODULE__)
  end

  def init({state, opts}) do
    {:ok, state, opts}
  end

  # :enter EVENT type, OLD STATE, CURRENT/NEW STATE, data
  def handle_event(:enter, _, :red, data) do
    IO.puts("\n\nThe light is currently Red")
    # red state recieves an event called green after 5 seconds.
    # list of ACTIONS; actions are taken on whatever stae you're ENTERING,
    # but not necessarily EVENTS
    # :state_time, the event type is :state_timeout
    # {:next_event, :internal, event_CONTENT}: :next_event, :internal is the event type, event_data is not STATE data, but it is 
    {:keep_state_and_data, [{:state_timeout, 5_000, :change}]}
  end

  def handle_event(:state_timeout, :change, :red, data) do
    IO.puts("\n\nSTATE TRANSITION from RED to GREEN")
    # So, this gets hit, then tries to call 
    # transitioning to green, and sending the event in the parens TO GREEN
    {:next_state, :green, data}
  end

  def handle_event(:enter, :red, :green, data) do
    IO.puts("\n\nThe light is currently GREEN")
    {:keep_state_and_data, [{:state_timeout, 5_000, :change}]}
  end

  def handle_event(:state_timeout, :change, :green, data) do
    IO.puts("\n\nSTATE TRANSITION from GREEN to YELLOW")
    # So, this gets hit, then tries to call 
    # transitioning to green, and sending the event in the parens TO GREEN
    {:next_state, :yellow, data}
  end

  def handle_event(:enter, :green, :yellow, data) do
    IO.puts("\n\nThe light is currently YELLOW")
    {:keep_state_and_data, [{:state_timeout, 5_000, :change}]}
  end

  def handle_event(:state_timeout, :change, :yellow, data) do
    IO.puts("\n\nSTATE TRANSITION from YELLOW to RED")
    # So, this gets hit, then tries to call 
    # transitioning to green, and sending the event in the parens TO GREEN
    {:next_state, :red, data}
  end

  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state, data, [{:reply, from, state}]}
  end
end
