defmodule EXNN.Trainer.Sync do
  use GenServer
  import EXNN.Utils.Logger
  alias EXNN.Trainer.Mutations

  @train_interval 100

  def start_link do
    GenServer.start_link(__MODULE__,
      :ok,
      name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{
      # stream: Stream.repeatedly(&train/0),
      fitness: {0, 0},
      counter: 0,
      attempts: 0,
      # TODO: get sensors from connectome for consistency
      sensors: EXNN.Config.sensors,
      max_attempts: 1000, # Conf.max_attempts
      reverts_count: 0,
      max_reverts: 500
      }
    }
  end

  def sync(data\\%{}) do
    GenServer.call __MODULE__, {:sync, data}
  end

  # public for testing

  def train(sensors) do
    sensors |> Enum.each(&sync_sensor/1)
  end

  # private

  def sync_sensor(sensor_id) do
    :ok = EXNN.NodeServer.forward(sensor_id, :sync, self)
  end

  def schedule_training_task(sensors) do
    {:ok, pid} = Task.start __MODULE__, :train, [sensors]
    ref = Process.monitor pid
    # train
    {:ok, ref}
  end

  # def handle_call {:fitness, value}, _from, state do
  #   if state.counter > state.max_attempts do
  #     Process.exit self, :terminate
  #   end
  #   {last, old} = state.fitness
  #   state = %{state | counter: state.counter + 1, fitness: {value, last}}
  #   {:reply, state , state}
  # end

  def handle_call {:sync, %{fitness: value}}, _from, state do
    {last, old} = state.fitness
    log "FITNESS ARRIVED", state, :debug
    log "with value: ", value

    reverts_count = state.reverts_count

    if state.counter > state.max_attempts do
      Process.exit self, :terminate
    end

    if reverts_count > state.max_reverts do
      raise("MaxDiscardsReached")
    end

    if value < last do
      log "<< reverting >>", "", :debug
      Mutations.revert
      reverts_count = reverts_count + 1
      Mutations.step
    else
      Mutations.step
      reverts_count = 0
    end

    ref = schedule_training_task state.sensors

    state = %{state |
      counter: state.counter + 1,
      reverts_count: reverts_count,
      fitness: {value, last}
    }

    {:reply, :ok, state}
  end

  def handle_call {:sync, %{}}, _from, state do
    ref = schedule_training_task state.sensors
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    IO.puts "/////// Sync DOWN with reason: #{inspect(_reason)} ////////////////////"
    {:noreply, state}
  end
end
