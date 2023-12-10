defmodule FsmPlayground.TrafficLight do
  @moduledoc """
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

  # (enter, OldState, State, Data)
  def handle_event(:enter, :red, _, _data) do
    IO.puts("The light is currently Red")
    {:keep_state_and_data, [{:state_timeout, 5_000, :green}]}
  end

  def handle_event(:state_timeout, :green, :red, _data) do
    IO.puts("The light is currently GREEN (from red)")
    {:keep_state_and_data, [{:state_timeout, 8_000, :yellow}]}
  end

  def handle_event(:state_timeout, :yellow, _what_is_this?, _data) do
    IO.puts("The light is currently YELLOW (from green...?)")
    {:keep_state_and_data, [{:state_timeout, 3_000, :red}]}
  end

  def handle_event(:state_timeout, :red, _what_is_this?, _data) do
    IO.puts("The light is currently RED (from yellow...?)")
    {:keep_state_and_data, [{:state_timeout, 5_000, :green}]}
  end

  # TODO: Enter callbacks are never called... something to do with the state_timeout?
  # def handle_event(:enter, :red, :green, _data) do
  #  IO.puts("ENTER: The light is currently Red")
  #  {:keep_state_and_data, [{:state_timeout, 5_000, :green}]}
  # end

  def handle_event(:enter, :green, :red, _data) do
    IO.puts("ENTER: The light is currently Green")
    {:keep_state_and_data, [{:state_timeout, 8_000, :yellow}]}
  end

  def handle_event(:enter, :yellow, :green, _data) do
    IO.puts("ENTER: The light is currently Yellow")
    {:keep_state_and_data, [{:state_timeout, 3_000, :red}]}
  end

  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state, data, [{:reply, from, state}]}
  end
end
