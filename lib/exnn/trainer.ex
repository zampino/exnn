defmodule EXNN.Trainer do
  use Supervisor
  use EXNN.Utils.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    []
    |> child(EXNN.Fitness.Supervisor, :supervisor, [])
    |> child(EXNN.Trainer.Sync, [])
    # |> child(EXNN.Fitness.Starter)
    |> supervise(strategy: :one_for_all)
  end

end
