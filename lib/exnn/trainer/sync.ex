defmodule EXNN.Trainer.Sync do
  use GenServer
  require Logger

  alias EXNN.Trainer.Mutations

  @tolerance 0.001

  @train_interval 100

  def start_link do
    GenServer.start_link(__MODULE__,
      :ok,
      name: __MODULE__)
  end

  # TODO: make params configurable over Conf
  def init(:ok) do
    {:ok,
      %{
        fitness: 0,
        counter: 0,
        # TODO: get sensors from connectome for consistency
        sensors: EXNN.Config.sensors,
        max_attempts: 2000,
        restarts: 0,
        reverts_count: 0,
        max_reverts: 80
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
    {:ok, ref}
  end

  def handle_call {:sync, %{fitness: value}}, _from, state do
    new_state = cond do
      state.counter > state.max_attempts      -> exit(:normal)
      state.reverts_count > state.max_reverts -> reset(state)
      value <= state.fitness                  -> less_fit(state)
      true                                    -> fitter(state, value)
    end
    Logger.info "[EXNN.Trainer.Sync] - sync - last fitness: #{inspect state}"
    Mutations.step
    # TODO:
    # queued_new_sensors -> block mutate adding links -> update state.sensors -> release
    {:ok, _ref} = schedule_training_task state.sensors
    {:reply, :ok, %{new_state | counter: new_state.counter + 1}}
  end

  def handle_call {:sync, %{}}, _from, state do
    {:ok, _ref} = schedule_training_task state.sensors
    {:reply, :ok, state}
  end

  def handle_info {:DOWN, _ref, :process, _pid, reason}, state do
    if reason != :normal do
      Logger.error "[EXNN.Trainer.Sync] task down with reason: #{inspect reason}"
    end
    {:noreply, state}
  end

  defp reset(%{restarts: count}=state) do
    Mutations.reset
    %{state | reverts_count: 0, restarts: count + 1}
  end

  defp less_fit(%{reverts_count: count}=state) do
    Mutations.revert
    %{state | reverts_count: count + 1}
  end

  defp fitter(state, value) do
    %{state | fitness: value, reverts_count: 0}
  end
end
