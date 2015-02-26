defmodule EXNN.Neuron do
  @moduledoc """
    # Neuron Data Structure

    ### Attributes
    - ins: is a keyword store which maps id -> weight
           and describes with which weight a neuron is attached as
           input.
  """
  use EXNN.NodeServer

  defstruct id: nil, ins: [], outs: [], bias: 0,
    activation: &EXNN.Math.id/1, acc: [], trigger: []

  def initialize(genome) do
    Dict.merge(genome, trigger: Dict.keys(genome.ins), acc: [])
  end

  @doc "broadcast input to registered outs and resets its trigger"
  def fire(%__MODULE__{trigger: []} = neuron) do
    {neuron, value} = impulse(neuron)
    neuron.outs |>
    Enum.each &(GenServer.cast(&1, {:signal, {neuron.id, value}}))

    %__MODULE__{neuron | trigger: Dict.keys(neuron.ins)}
  end

  def fire(neuron) do
    neuron
  end

  def impulse(neuron) do
    {activation_input, acc} = List.foldl(neuron.ins,
                                        {0, neuron.acc},
                                        &EXNN.Math.labelled_scalar_product/2)

    neuron = %__MODULE__{neuron | acc: acc}
    _impulse = neuron.activation.(activation_input + neuron.bias)
    {neuron, _impulse}
  end

  def signal(neuron, {origin, value}) do
    acc = neuron.acc ++ [{origin, value}]
    trigger = List.delete(neuron.trigger, origin)
    %__MODULE__{neuron | trigger: trigger, acc: acc}
    |> fire
  end

  defimpl EXNN.Connection, for: __MODULE__ do
    def signal(neuron, {origin, value}) do
      IO.puts "---- signaling neuron: #{neuron.id} -- #{inspect(neuron)} ------"
      EXNN.Neuron.signal(neuron, {origin, value})
    end
  end

end
