defmodule EXNN.NodeServerTest do
  use ExUnit.Case

  def start_neuron_with(weights, bias\\0) do
    {:ok, neuron} = EXNN.Neuron.new(weights, bias: bias)
    neuron
  end

  # test "it should fail if I start the neuron with wrong params" do
  #   block = fn() -> start_neuron_with "some string" end
  #   assert_raise FunctionClauseError, block
  # end
  #
  # test "sense computation" do
  #   neuron = start_neuron_with [1, 2, 3], 1
  #   assert EXNN.Neuron.sense(neuron, [0, 1, 1]) == 6
  #   assert EXNN.Neuron.sense(neuron, [1, 0, 0]) == 2
  # end
  #
  # test "sense computation with floats" do
  #   neuron = start_neuron_with [0.1, 0.5, 0.3], 1.1
  #   val1 = EXNN.Neuron.sense(neuron, [0, 0, 1])
  #   val2 = EXNN.Neuron.sense(neuron, [1, 2, 1])
  #   assert_in_delta val1, 1.4, 0.0001
  #   assert_in_delta val2, 2.5, 0.0001
  # end
  #
  # test "sense computation default bias" do
  #   {:ok, neuron} = EXNN.Neuron.new([0.1, 0.5, 0.3])
  #   val = EXNN.Neuron.sense(neuron, [1, 1, 1])
  #   assert_in_delta val, 0.9, 0.0001
  # end
end
