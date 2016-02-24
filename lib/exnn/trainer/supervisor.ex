defmodule EXNN.Trainer.Supervisor do
  use Supervisor
  use EXNN.Utils.Supervisor

  def start_link app do
    IO.puts "\n\n receiveing #{inspect app}\n\n"
    Supervisor.start_link(__MODULE__, app)
  end

  def init app do
    IO.puts "starting trainer supervisor with: #{inspect app}"
    []
    |> child(EXNN.Fitness.Starter, [])
    |> child(EXNN.Trainer.Mutations, [])
    |> child(EXNN.Trainer.Sync, [app])
    |> supervise(strategy: :one_for_all)
  end
end
