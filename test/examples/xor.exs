defmodule XORApp do
  use EXNN.Application

  sensor :s, XORApp.Domain, dim: 2
  actuator :a, XORApp.Range
  fitness XORApp.Fitness

  initial_pattern([
    sensor: [:s],
    neuron: {2, 1},
    actuator: [:a]
  ])

  train_with mode: :continuous, stable_after: 10, tolerance: 0.01, epochs: 5_000

  def start(_, _) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(EXNN.Supervisor, [[config: __MODULE__]])
    ]
    opts = [strategy: :one_for_one, name: HostApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule XORApp.Domain do
  use EXNN.Sensor,
    state: [
      domain: [{-1, -1}, {-1, 1}, {1, -1}, {1, 1}]
    ]

  def sync(sensor, _meta) do
    forward_each = fn(item)->
      forward(sensor, item)
    end
    :ok = sensor.domain |> Enum.each(forward_each)
    sensor
  end
end

defmodule XORApp.Range do
  use EXNN.Actuator, state: []

  def act(state, message, meta) do
    state
  end
end

defmodule XORApp.Fitness do
  @domain [{-1, -1}, {-1, 1}, {1, -1}, {1, 1}]
  alias EXNN.Utils.Math


  use EXNN.Fitness, state: [
    trigger: @domain,
    acc: []
  ]

  # Fitness server is hit with genserver calls of the kind:
  # {{sens_id, original_impulse}, {actuator_id, received_impulse}}
  # for each impulse the actuator receives

  # XOR(x, y) = - x*y
  def diff_squared({{x_1, x_2}, y}) do
    (y + x_1*x_2) * (y + x_1*x_2) # value - XOR(x, y)
  end

  def distance_squared(state) do
    acc = state.acc
    # log "computed: ", acc
    acc |> Enum.map(&diff_squared/1) |> Enum.sum # |> Math.sqrt
  end

  def eval([neuron_l2_1: y], [s: x], state) do
    update(state, x, y) |> fire()
  end

  def eval(_, _, state) do
    IO.puts "unhandled case"
    state
  end

  def fire(%{trigger: []} = state) do
    :ok = emit 1/(1 + distance_squared(state))
    %{state | acc: [], trigger: @domain}
  end

  def fire(state), do: state

  def update(state, x, y) do
    acc = [{x, y} | state.acc]
    trigger = List.delete state.trigger, x
    %{state | trigger: trigger, acc: acc}
  end
end

defmodule XORTest do
  require Logger
  use ExUnit.Case, async: true

  setup do
    {:ok, _pid} = XORApp.start(:normal, [])
    IO.puts "starting app"

    on_exit fn ->
      XORApp.stop(:normal)
      IO.puts "terminating app: XOR"
    end

    {:ok, []}
  end

  test "X or runs!" do
    :ok = EXNN.Trainer.start reporter: self

    assert_receive {:report, state}, 5_000
    Logger.info "\nTrained stably to #{inspect state.fitness} in #{state.fit_after} ms\n"
    Logger.info inspect state
  end
end
