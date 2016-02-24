defmodule EXNN.Supervisor do
  use Supervisor
  use EXNN.Utils.Supervisor

  def start_link([config: mod]) do
    Supervisor.start_link(__MODULE__, mod)
  end

  # TODO: group workers in parent-supervisors

  def init(mod) do
    []
    |> child(EXNN.Config, [mod])
    |> child(EXNN.Events, :supervisor, [])
    |> child(EXNN.Connectome, [])
    |> child(EXNN.NodeSupervisor, :supervisor, [])
    |> child(EXNN.Nodes, [])
    |> child(EXNN.Nodes.Loader, [])
    |> child(EXNN.Trainer.Supervisor, :supervisor, [mod])
    |> supervise(strategy: :one_for_one)
  end

end
