defmodule EXNN.Trainer.Mutations.Agent do
  @moduledoc false
  alias EXNN.Trainer.Mutations.Set.Mutation

  def apply mutation_set do
    mutation_set
    |> Enum.map(&spawn_async_task/1)
    |> EXNN.Utils.Task.wait_all

    {:ok, EXNN.Connectome.neurons}
  end

  def spawn_async_task(mutation) do
    Task.async __MODULE__, :apply_mutation, [mutation]
  end

  # TODO: REFACTOR WITH A MUTATION PROTOCOL
  # - Mutation is a struct e.g. Mutation.AlterWeights which implements a Mutation protocl
  # mutation_set
  # |> expand
  # |> Enum.map &spawn_task
  #
  # expand
  # Mutation.expand mutation => list of mutation patches
  # def apply_mutation mutation_struct do
  #   patch_args = Mutation.apply mutation_struct
  #   results = apply EXNN.NodeServer :patch, patch_args
  #   results |> Enum.each
  # end
  # NOTE: A MUTATION COULD INVOLVE MORE THAN ONE NODE!!!

  def apply_mutation(%Mutation{
    type: type,
    id: id,
    changes: changes}) when type in [:alter_weights, :reset_weigths] do

    patch_fn = fn(genome)->
      new_weights = changes |> Enum.reduce(genome.ins, fn({key, _old, new}, weights)->
        Keyword.put weights, key, new
      end)
      %{ins: new_weights}
    end

    res = EXNN.NodeServer.patch(id, patch_fn)
    EXNN.Connectome.update(id, res)
  end

  def apply_mutation(%Mutation{
    type: _type,
    id: id,
    changes: {:bias, _old, new}}) do

    patch_fn = fn(_genome)->
      %{bias: new}
    end

    res = EXNN.NodeServer.patch(id, patch_fn)
    EXNN.Connectome.update(id, res)
  end
end
