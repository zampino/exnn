defmodule EXNN.Trainer.Mutations do
  use GenServer

  alias EXNN.Trainer.Mutations.Set
  alias EXNN.Trainer.Mutations.Agent

  import EXNN.Utils.Logger

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

  # server callbacks

  def handle_call :step, _from, state do
    log "step", [], :debug
    mutation_set = Set.generate(state.neurons)
    {:ok, neurons} = Agent.apply mutation_set

    {:reply, :ok, %{state |
      neurons: neurons,
      history: [mutation_set | state.history]}
    }
  end

  def handle_call :revert, _from, state do
    log "revert", [], :debug
    [mutation_set | rest] = state.history
    inverse_set = Set.invert mutation_set
    {:ok, neurons} = Agent.apply inverse_set
    {:reply, :ok, %{state | neurons: neurons, history: rest}}
  end
end
