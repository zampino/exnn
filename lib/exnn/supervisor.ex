defmodule EXNN.Supervisor do
  use Supervisor

  def start_link([config: mod]) do
    Supervisor.start_link(__MODULE__, mod)
  end

  def init(mod) do
    IO.puts "start super with #{inspect(mod)}"
    []
    # |> child(EXNN.Cortex)
    |> child(EXNN.Connectome, [])
    |> child(EXNN.Store, [mod])
    |> supervise(strategy: :one_for_one)
  end

  defp child(previous, mod, args) do
    [worker(mod, args) | previous]
  end

end
