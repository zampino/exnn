defmodule EXNN.Trainer.Mutations do
  use GenServer

  alias EXNN.Trainer.Mutations.Set
  alias EXNN.Trainer.Mutations.Agent

  

  def start_link do
    GenServer.start_link __MODULE__,
      :ok,
      name: __MODULE__
  end

  def init :ok do
    {:ok, %{
      neurons: EXNN.Connectome.neurons,
      history: []
    }}
  end

  # client api

  def step do
    GenServer.call __MODULE__, :step
  end

  def revert do
    GenServer.call __MODULE__, :revert
  end

  def reset do
    GenServer.call __MODULE__, :reset
  end

  # server callbacks

  def handle_call :step, _from, state do
    mutation_set = Set.generate(state.neurons)
    {:ok, neurons} = Agent.apply mutation_set
    {:reply, :ok, %{state |
      neurons: neurons,
      history: [mutation_set | state.history]}
    }
  end

  def handle_call :revert, _from, state do
    [mutation_set | rest] = state.history
    {:ok, neurons} = Set.invert(mutation_set) |> Agent.apply
    {:reply, :ok, %{state | neurons: neurons, history: rest}}
  end

  def handle_call :reset, _from, state do
    mutation = Set.reset(state.neurons)
    {:ok, neurons} = Agent.apply mutation
    {:reply, :ok, %{state | neurons: neurons, history: []}}
  end
end
