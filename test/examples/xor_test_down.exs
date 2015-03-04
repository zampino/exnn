defmodule XORTest do


end


defmodule XOR do
  use EXNN.Application

  set_sensor :s, Domain, dim: 2
  set_actuator :a, CoDomain
  set_fitness :f, Fitness

  set_initial_pattern [
    sensor: [:s],
    neuron: {2, 1},
    actuator: [:a]
  ]

end

defmodule Domain do
  use EXNN.Sensor,
    with_state: [domain: [{-1, -1}, {-1, 1}, {1, -1}, {1, 1}]]

  def sync(sensor, _) do
    forward_each = fn(item)->
      forward(sensor, item)
    end
    sensor.domain |> Enum.each(forward_each)
    sensor
  end

end

defmodule Fitness do
  use EXNN.Fitness,
    with_state: [
      trigger: [{-1, -1}, {-1, 1}, {1, -1}, {1, 1}],
      acc: %{}
    ]

  # Fitness server is hit with genserver calls of the kind:
  # {{sens_id, original_impulse}, {actuator_id, received_impulse}}
  # for each impulse the actuator receives

  def diff_squared(value, {x, y}) do
    (value - x*y)^2
  end

  def eval_fitness(fitness, {{_, impulse}, {_, computed_value}}) do
    update(fitness, impulse, computed_value)
    emit(fitness)
  end

  def emit(%__MODULE__{trigger: [], acc: acc} = fitness) do
    Enum.foldl()
  end

  def update(fitness, impulse, value) do
    new_trigger = List.delete fitness.trigger, impulse
    new_acc = Map.put fitness.acc, impulse, value
    %__MODULE__{fitness, trigger: new_trigger, acc: new_acc}
  end
  # server callbacks



end
