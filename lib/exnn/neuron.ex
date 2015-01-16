defmodule EXNN.Neuron do
  use EXNN.NodeServer
  @moduledoc """
    # Neuron Data Structure

    ### Attributes
    - ins: is a keyword store which maps id -> weight
           and describes with which weight a neuron is attached as
           input.
  """
  defstruct id: nil, ins: [], outs: [], bias: 0,
    activation: &EXNN.Math.tanh/1, acc: [], trigger: []

  def new(map) do
    struct(__MODULE__, map)
  end

  def init(genome) do
    genome
    |> Dict.merge(trigger: Dict.keys(genome.ins), acc: [])
    |> new
  end

  @doc "broadcast input to registered outs and resets its trigger"
  def fire(%__MODULE__{trigger: []} = neuron) do
    {neuron, _impulse} = impulse(neuron)
    neuron.outs |>
      Enum.each &(GenServer.cast(&1, {:signal, {neuron.id, _impulse}}))

    %EXNN.Neuron{neuron | trigger: Dict.keys(neuron.ins)}
  end

  def fire(neuron) do
    neuron
  end

  def impulse(neuron) do
    vector_product = fn {id, weight}, {memo, acc} ->
      {val, acc} = Keyword.pop_first acc, id
      {memo + weight * val, acc}
    end
    {activation_input, neuron_acc} = List.foldl neuron.ins, {0, neuron.acc}, vector_product
    neuron = %__MODULE__{neuron | acc: neuron_acc}
    _impulse = neuron.activation.(activation_input + neuron.bias)
    {neuron, _impulse}
  end

  defimpl EXNN.Connection, for: __MODULE__ do
    def signal(neuron, {origin, value}) do
      acc = neuron.acc ++ [{origin, value}]
      trigger = List.delete(neuron.trigger, origin)
      %EXNN.Neuron{neuron | trigger: trigger, acc: acc}
      |> EXNN.Neuron.fire
    end
  end

end
