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
  ]

  def generate(neurons) do
    length = Enum.count neurons
    candidates = Random.sample neurons, Math.inv_sqrt(length)
    Enum.map candidates, &generate_for(&1)
  end

  def generate_for(genome) do
    # type = Random.sample @mutation_types
    Mutation.new genome, type: :alter_weights
  end

  def invert(set), do: invert(set, [])

  def invert([], done), do: done

  def invert([first|rest], done) do
    invert(rest, [Mutation.inverse(first) | done])
  end

  defmodule Mutation do
    defstruct type: nil, id: nil, changes: []

    def new(genome, type: type) do
      struct(__MODULE__, [type: type, id: genome.id])
      |> build_changes(genome)
    end

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

    def inverse(%Mutation{type: :alter_weights, changes: changes}=mutation) do
      inverse_changes = Enum.map changes,
        fn({key, old, new}) -> {key, new, old} end
      %{mutation | changes: inverse_changes}
    end
  end
end
