defmodule EXNN.Trainer.Mutations.Set do
  @moduledoc false
  import EXNN.Utils.Logger

  alias EXNN.Utils.Math
  alias EXNN.Utils.Random
  alias EXNN.Trainer.Mutations.Set.Mutation
  # alias EXNN.Config

  @mutation_types [
    :alter_weights,
    # :add_link,
    # :delete_link,
    # :add_node,
    # :remove_node
    :alter_bias
    # :alter_activation
    # :swap_activation
  ]

  def generate(neurons) do
    Random.seed
    length = Enum.count neurons
    candidates = Random.sample neurons, Math.inv_sqrt(length)
    Enum.map candidates, &generate_for(&1)
  end

  def reset(neurons) do
    Random.seed
    do_reset(neurons, [])
  end

  def invert(set), do: invert(set, [])

  defp generate_for(genome) do
    Mutation.new genome, type: Random.take(@mutation_types)
  end

  defp invert([], done), do: done

  defp invert([first|rest], done) do
    invert(rest, [Mutation.inverse(first) | done])
  end

  defp do_reset([], acc), do: acc

  defp do_reset([neuron | rest], acc) do
    do_reset rest, [ Mutation.new(neuron, type: :reset_weigths) |
      [ Mutation.new(neuron, type: :reset_bias) |
        acc
      ]
    ]
  end

  defmodule Mutation do
    defstruct type: nil, id: nil, changes: []

    def new(genome, type: type) do
      log "MUTATE:", {genome.id, type}, :debug
      struct(__MODULE__, [type: type, id: genome.id]) |> build_changes(genome)
    end

    # Alter weights

    def build_changes %Mutation{type: :alter_weights}=mutation, genome do
      weights = genome.ins
      keys = Keyword.keys(weights)
      length = Enum.count keys
      space = Math.inv_sqrt(length)
      sampled = keys |> Random.sample(space)
      sampled |> Enum.reduce mutation, fn(key, acc)->
        old = weights[key]
        new = Random.coefficient(old)
        %{acc | changes: [{key, old, new} | acc.changes]}
      end
    end

    def inverse %Mutation{type: :alter_weights, changes: changes}=mutation do
      inverse_changes = Enum.map changes,
        fn({key, old, new}) -> {key, new, old} end
      %{mutation | changes: inverse_changes}
    end

    # Reset Weights

    def build_changes %Mutation{type: :reset_weigths}=mutation, genome do
      weights = genome.ins

      Keyword.keys(weights)
      |> Enum.reduce mutation, fn(key, acc)->
        old = weights[key]
        new = Random.uniform
        %{acc | changes: [{key, old, new} | acc.changes]}
      end
    end

    # Alter Bias
    def build_changes %Mutation{type: :alter_bias}=mutation, genome do
      bias = genome.bias
      %{mutation | changes: {:bias, bias, Random.coefficient(bias)}}
    end

    def inverse %Mutation{type: :alter_bias, changes: {:bias, old, new}}=mutation do
      %{mutation | changes: {:bias, new, old}}
    end

    def build_changes %Mutation{type: :reset_bias}=mutation, genome do
      bias = genome.bias
      %{mutation | changes: {:bias, bias, EXNN.Genome.random_bias}}
    end

  end
end
