defmodule EXNN.Fitness.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link __MODULE__, :ok, name: __MODULE__
  end

  def start_fitness(mod) do
    child_spec = worker(mod, [], restart: :temporary)
    {:ok, _} = Supervisor.start_child __MODULE__, child_spec
  end

  def init(:ok) do
    supervise [], strategy: :one_for_all
  end

end
