defmodule EXNN.Trainer.SyncTest do
  use ExUnit.Case

  setup_all do
    {_maybe_ok, _pid} = HostApp.start(:normal, [])

    on_exit fn ->
      HostApp.stop(:normal)
      IO.puts "terminating app"
    end

    :ok
  end

  test "train/1 It should launch a first Training task" do
    iterations = 1000
    sensors = EXNN.Config.sensors

    1..iterations
    |> Enum.each(fn(_x)->
      EXNN.Trainer.Sync.train(sensors)
    end)

    recorded = GenServer.call(:a_1, :store)
    meta = GenServer.call(:a_1, :meta)

    IO.puts "==== #{inspect(recorded)} ========== #{length(recorded)} ========="
    IO.puts "**** #{inspect(meta)} ************** #{Dict.size(meta)} **********"

    assert length(recorded) == 2*iterations
    assert Dict.size(meta) == 2*iterations

    refute Enum.empty?(recorded)
  end
end
