defmodule EXNN.Supervisor do
  use Supervisor

  def start_link([config: mod]) do
    Supervisor.start_link(__MODULE__, mod)
  end

  def init(mod) do
    []
    |> child(EXNN.Config, [mod])
    |> child(EXNN.Connectome, [])
    |> child(:supervisor, EXNN.NodeSupervisor, [])
    |> child(EXNN.Nodes, [])
    # |> child(:supervisor, EXNN.Nodes.Loader, [])
    |> supervise(strategy: :one_for_one)
  end

  defp child(previous, type\\:worker, mod, args) do
    _worker = worker_for(type, mod, args)
    previous ++ [_worker]
  end

  defp worker_for(:worker, mod, args) do
    worker(mod, args)
  end

  defp worker_for(:supervisor, mod, args) do
    supervisor(mod, args)
  end

end
