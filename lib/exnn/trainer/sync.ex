defmodule EXNN.Trainer.Sync do
  require Logger
  alias EXNN.Trainer.Mutations
  import EXNN.Strategies, only: [runtime_strategy: 4]

  @behaviour :gen_fsm
  def terminate(a, b, c), do: raise("Terminate - #{inspect {a, b, c}}")
  def handle_event(_, _, _), do: raise("NotImplemented")
  def handle_sync_event(_, _, _, _), do: raise("NotImplemented")
  def code_change(_, _, _, _), do: raise("NotImplemented")

  def start_link(app_name) do
    IO.puts "#{__MODULE__} starting with #{inspect app_name}"
    :gen_fsm.start_link {:local, __MODULE__}, __MODULE__, app_name, []
  end

  # TODO: make params configurable over Conf
  def init app_name do
    state = runtime_strategy(app_name, __MODULE__, :init, [])
    |> Map.merge(%{
      app_name: app_name,
      fitness: 0,
      counter: 0,
      restarts: 0,
      reverts_count: 0,
      stability_count: 0,
      sensors: EXNN.Config.sensors,
    })
    IO.puts "STATE: #{inspect {app_name, state}}"
    {:ok, :idle, state}
  end

  def sync(data\\%{}) do
    :gen_fsm.sync_send_event __MODULE__, {:sync, data}
  end

  def start(data\\%{}) do
    :gen_fsm.sync_send_event __MODULE__, {:start, data}
  end

  # public for testing

  def train(sensors) do
    sensors |> Enum.each(&sync_sensor/1)
  end

  # server callbacks / states
  # defp bootstrap(state, data) do
  #   keys = Map.keys(@defaults)
  #   allowed = Map.take data, keys
  #   state
  #   |> Map.merge(@defaults)
  #   |> Map.merge(allowed)
  # end

  def idle {:start, _data}, _from, state do
    state = state
      |> Map.merge(%{start_time: :erlang.monotonic_time(:milli_seconds)})
      {:ok, _ref} = schedule_training_task state.sensors
    {:reply, :ok, :learning, state} # bootstrap(state, data) }
  end

  def learning {:sync, %{fitness: value}}, _from, state do
    # TODO: MOVE THESE BRANCHES INTO A COMPILE TIME STRATEGY
    state = cond do
      state.counter > state.max_attempts      -> exit(:normal)
      state.reverts_count > state.max_reverts -> reset(state)
      value <= state.fitness                  -> less_fit(state)
      true                                    -> fitter(state, value)
    end
    Logger.info "[EXNN.Trainer.Sync] - sync - #{inspect state}\n"
    Mutations.step
    # TODO:
    # queued_new_sensors -> block mutate adding links -> update state.sensors -> release
    {:ok, _ref} = schedule_training_task state.sensors
    {:reply, :ok, :learning, %{state | counter: state.counter + 1}}
  end

  def learning :fit, state do
    time_diff = :erlang.monotonic_time(:milli_seconds) - state.start_time
    state = state
    |> Map.merge(%{fit_after: time_diff})
    |> EXNN.Trainer.Reporter.dump
    {:next_state, :online, state}
  end

  def online {:sync, %{fitness: value}}, _from, state do
    Logger.debug "[EXNN.Trainer.Sync] - online - ignore fitness: #{inspect value}"
    {:reply, :ok, :online, state}
  end

  def handle_info {:DOWN, _ref, :process, _pid, reason}, state_name, state do
    if reason != :normal do
      Logger.error "[EXNN.Trainer.Sync] task down with reason: #{inspect reason}"
    end
    {:next_state, state_name, state}
  end

  defp sync_sensor(sensor_id) do
    :ok = EXNN.NodeServer.forward(sensor_id, :sync, self)
  end

  defp schedule_training_task(sensors) do
    {:ok, pid} = Task.start __MODULE__, :train, [sensors]
    ref = Process.monitor pid
    {:ok, ref}
  end

  defp reset(%{restarts: count}=state) do
    Mutations.reset
    %{state | reverts_count: 0, stability_count: 0, restarts: count + 1}
  end

  defp less_fit(%{reverts_count: count}=state) do
    Mutations.revert
    %{state | reverts_count: count + 1}
  end

  defp fitter(%{app_name: app, tolerance: t} = state,
    fitness) when (1 - t) < fitness do
    # stability_count: count
    # stable_after: stable_after} = state,
    # state = EXNN.Strategies.Trainer.sync_fitter_strategy(__MODULE__, state)
    runtime_strategy(app, __MODULE__, :fitter, [state])
    |> (&%{&1 | fitness: fitness, reverts_count: 0}).()
  end

  defp fitter(state, fitness) do
    %{state | fitness: fitness, reverts_count: 0}
  end
end
