defmodule FsmPlayground.Silly do
  use GenStateMachine, callback_mode: [:handle_event_function, :state_enter]

  def start_link(_opts) do
    # GenStateMachine.start_link(__MODULE__, {:first, []}, name: __MODULE__)
    GenStateMachine.start_link(__MODULE__, {1, []}, name: __MODULE__)
  end

  def child_spec(init_args) do
    %{id: __MODULE__, restart: :transient, start: {__MODULE__, :start_link, [init_args]}}
  end

  def init({state, opts}) do
    # {:ok, state, opts, [{:next_event, :internal, {:transition, :second}}]}
    {:ok, state, opts, [{:next_event, :internal, {:transition, state + 1}}]}
  end

  def handle_event(:internal, {:transition, to_state}, _, data) do
    IO.puts("TRANSITION TO #{to_state}")

    {:next_state, to_state, data, [{:next_event, :internal, {:transition, to_state + 1}}]}
  end

  # def handle_event(:internal, {:transition, to_state}, _, data) do
  #  IO.puts("TRANSITION TO #{to_state}")

  #  next_state =
  #    case to_state do
  #      :first -> :second
  #      :second -> :third
  #      :third -> :fourth
  #      :fourth -> :first
  #    end

  #  {:next_state, to_state, data, [{:next_event, :internal, {:transition, next_state}}]}

  #  # case to_state do
  #  #  :first -> {:next_state, to_state, data, [{:next_event, :internal, {:transition, :second}}]}
  #  #  :second -> {:next_state, to_state, data, [{:next_event, :internal, {:transition, :third}}]}
  #  #  :third -> {:next_state, to_state, data, [{:next_event, :internal, {:transition, :fourth}}]}
  #  #  :fourth -> {:next_state, to_state, data}
  #  # end
  # end

  def handle_event(:enter, _, :fourth, data) do
    IO.puts("ENTERING FOURTH")
    {:stop, :normal, data}
  end

  def handle_event(:enter, _, 4, data) do
    IO.puts("ENTERING 4")
    {:stop, :normal, data}
  end

  def handle_event(:enter, _, current_state, _data) do
    IO.puts("ENTERING #{current_state}")
    :keep_state_and_data
  end

  def terminate(:normal, state, _data) do
    IO.puts("THIS IS OVER from state: #{state}")
  end
end
