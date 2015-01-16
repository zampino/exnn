defmodule EXNN.PatternTest do
  use ExUnit.Case

  test "building connectome from pattern" do
    pattern = [sensor: [:s1, :s2], neuron: {3, 2}, actuator: 1]
    layers = EXNN.Pattern.build_layers pattern
    assert layers == [
      actuator: [:actuator_1],
      neuron: [:neuron_l2_1, :neuron_l2_2],
      neuron: [:neuron_l1_1, :neuron_l1_2, :neuron_l1_3],
      sensor: [:s1, :s2]
    ]
  end
end
