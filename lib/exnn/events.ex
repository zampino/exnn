defmodule EXNN.Events do
  use Supervisor
  use EXNN.Utils.Supervisor

  def start_link do
    Supervisor.start_link __MODULE__, :ok
  end

  def init(:ok) do
    []
    |> child(EXNN.Events.Manager, [])
    # |> child(EXNN.Events.Stream, [])
    |> supervise(strategy: :one_for_all)
  end

end
