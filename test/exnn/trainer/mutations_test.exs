defmodule EXNN.Trainer.MutationsTest do
  alias EXNN.Trainer.Mutations.Set
  alias EXNN.Trainer.Mutations.Agent
  

  use ExUnit.Case

  setup_all do
    {_maybe_started, _pid} = HostApp.start(:normal, [])
    on_exit(fn -> HostApp.stop(:normal) end)
    :ok
  end

  test "Generate a Mutation" do
    mutation_set = EXNN.Connectome.neurons |> Set.generate()
    Enum.each mutation_set, fn(mutation)->
      assert match?(%Set.Mutation{}, mutation)
    end
  end

  test "Apply a Mutation" do
    mutation = EXNN.Connectome.neurons |> Set.generate() |> List.first
    Agent.apply_mutation mutation
  end

end
