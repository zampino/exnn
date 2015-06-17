
defmodule HostApp do
  use EXNN.Application

  set_initial_pattern [
    sensor: [:s_1, :s_2],
    neuron: {3, 2},
    actuator: [:a_1]
  ]

  set_sensor :s_1, HostApp.SensOne, dim: 1
  set_sensor :s_2, HostApp.SensTwo, dim: 2
  set_actuator :a_1, HostApp.Recorder

  def start(_type, _args\\[]) do
    import Supervisor.Spec #, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(HostApp.Worker, [arg1, arg2, arg3])
      supervisor(EXNN.Supervisor, [[config: __MODULE__]])
    ]

    opts = [strategy: :one_for_one, name: :host_app] # HostApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end


defmodule HostApp.Recorder do
  use EXNN.Actuator, state: [store: [], meta: []]

  def act(state, message, meta) do
    %{state |
      store: state.store ++ message,
      meta: [meta | state.meta]}
  end

  def handle_call(:store, _from, state) do
    {:reply, state.store, state}
  end

  def handle_call(:meta, _from, state) do
    {:reply, state.meta, state}
  end
end

defmodule HostApp.SensOne do
  use EXNN.Sensor

  def sense(sensor, _meta) do
    {0.1}
  end
end

defmodule HostApp.SensTwo do
  use EXNN.Sensor

  def sense(sensor, _meta) do
    {0.1, 0.9}
  end
end

ExUnit.start
