defmodule EXNN.Neuron do
  @moduledoc """
    # Neuron Data Structure

    ### Attributes
    - ins: is a keyword store which maps id -> weight
           and describes with which weight a neuron is attached as
           input.
  """
  use EXNN.NodeServer
  alias EXNN.Utils.Math

  defstruct id: nil, ins: [], outs: [], bias: 0,
    activation: nil, acc: [], trigger: [], metadata: []

  def initialize(genome) do
    Dict.merge(genome, trigger: Dict.keys(genome.ins), acc: [])
  end

  @doc "broadcast input to registered outs and resets its trigger"
  def fire(%{trigger: []} = neuron) do
    {neuron, value} = impulse(neuron)

    :ok = neuron.outs |>
    Enum.each(&forward(&1, neuron, value))

    %{neuron | trigger: Dict.keys(neuron.ins)}
  end

  def forward(out_id, neuron, value) do
    EXNN.NodeServer.forward(out_id, [{neuron.id, value}], neuron.metadata)
  end

  def fire(neuron) do
    neuron
  end

  def impulse(neuron) do
    {activation_input, acc} = List.foldl(neuron.ins,
                                        {0, neuron.acc},
                                        &Math.labelled_scalar_product/2)

    neuron = %{neuron | acc: acc}
    _impulse = neuron.activation.(activation_input + neuron.bias)
    {neuron, _impulse}
  end

  def signal(neuron, message, metadata\\[]) do
    acc = neuron.acc ++ message
    metadata = Dict.merge neuron.metadata, metadata
    trigger = Keyword.keys(message)
    |> List.foldl(neuron.trigger, fn(origin, trigger)->
      List.delete(trigger, origin)
    end)

    %{neuron | trigger: trigger, acc: acc, metadata: metadata}
    |> fire
  end

  defimpl EXNN.Connection do
    def signal(neuron, message, metadata) do
      EXNN.Neuron.signal(neuron, message, metadata)
    end
  end

end
