defmodule XORTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, _pid} = XORApp.start(:normal, [])

    on_exit fn ->
      XORApp.stop(:normal)
      IO.puts "terminating app: XOR"
    end

    {:ok, []}
  end

  test "X or runs!" do
    :ok = EXNN.Trainer.start
    :timer.sleep 5000
  end
end


defmodule XORApp do
  use EXNN.Application

  sensor :s, XORApp.Domain, dim: 2
  actuator :a, XORApp.Range
  fitness XORApp.Fitness, mode: :sync # :continuous

  set_initial_pattern [
    sensor: [:s],
    neuron: {2, 1},
    actuator: [:a]
  ]

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
  import EXNN.Utils.Logger

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
    log "computed: ", acc
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
