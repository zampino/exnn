defmodule EXNN.Trainer.Mutations.Agent do
  @moduledoc false
  import EXNN.Utils.Logger
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

  def apply_mutation %Mutation{
    type: :alter_weights,
    id: id,
    changes: changes} do

    patch_fn = fn(genome)->
      new_weights = changes |> Enum.reduce genome.ins, fn({key, old, new}, weights)->
        Keyword.put weights, key, new
      end
      %{ins: new_weights}
    end

    res = EXNN.NodeServer.patch(id, patch_fn)
    EXNN.Connectome.update(id, res)
  end
end
