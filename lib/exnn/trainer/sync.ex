defmodule EXNN.Trainer.Sync do
  use GenServer

  @train_interval 100

  def start_link do
    GenServer.start_link(__MODULE__,
      :ok,
      name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{
      stream: Stream.repeatedly(&train/0),
      fitness: {nil, nil},
      counter: 0,
      sensors: EXNN.Config.sensors
      }
    }
  end

  def train(state\\%{sensors: EXNN.Config.sensors}) do
    state.sensors |> Enum.each(&sync_sensor/1)
  end

  def sync_sensor(sensor_id) do
    :ok = EXNN.NodeServer.forward(sensor_id, :sync, self)
  end

  # CLIENT API

  def iterate(cycles) do
    GenServer.call __MODULE__, {:iterate, cycles}
  end

  def sync(%{fitness: value}) do
    state = GenServer.call __MODULE__, {:fitness, value}
    # react on new_state
    IO.puts "new state #{inspect(state)}\n\n"
    {:ok, pid} = Task.start __MODULE__, :train, [state]
    Process.monitor pid
    # train
    :ok
  end

  # SERVER CALLBACKS

  def handle_call({:iterate, num}, _from, state) do
    ^num = Enum.take(state.stream, num) |> length()
    {:reply, :ok, state}
  end

  def handle_call :train, _from, state do
    :ok = state.sensors |> Enum.each(&sync_sensor/1)
    {:reply, :ok, state}
  end

  def handle_call {:fitness, value}, _from, state do
    if state.counter > 10 do
      Process.exit self, :terminate
    end
    {last, old} = state.fitness
    state = %{state | counter: state.counter + 1, fitness: {value, last}}
    {:reply, state , state}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    IO.puts "/////// Sync DOWN with reason: #{inspect(_reason)} ////////////////////"
    {:noreply, state}
  end
end
