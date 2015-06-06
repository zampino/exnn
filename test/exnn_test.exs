defmodule EXNNTest do
  use ExUnit.Case

  @moduledoc """
    Integrative Testing of a remote applicaion
  """
  setup_all do
    {_maybe_ok, _pid} = HostApp.start(:normal, [])

    on_exit fn ->
      HostApp.stop(:normal)
      IO.puts "terminating app"
    end

    :ok
  end

  test "storing remote nodes and pattern in the store agent" do
    assert EXNN.Config.get_remote_nodes == [
      {:actuator, :a_1, HostApp.Recorder, []},
      {:sensor, :s_2, HostApp.SensTwo, [dim: 2]},
      {:sensor, :s_1, HostApp.SensOne, [dim: 1]}
    ]

    assert EXNN.Config.get_pattern == {
      [sensor: [:s_1, :s_2], neuron: {3, 2}, actuator: [:a_1]],
      [s_2: 2, s_1: 1]
    }
  end

  test "storing genomes" do
    origin = self
    genomes = Agent.get EXNN.Connectome, &(&1)

    assert HashDict.to_list(genomes) == [neuron_l1_3: %{id: :neuron_l1_3,
              ins: [s_1_1: 0.6971407843005519, s_2_1: 0.15981142006315596,
               s_2_2: 0.5582558083752902], outs: [:neuron_l2_1, :neuron_l2_2],
              type: :neuron},
            s_2: %{id: :s_2, outs: [:neuron_l1_1, :neuron_l1_2, :neuron_l1_3],
              type: :sensor},
            neuron_l1_2: %{id: :neuron_l1_2,
              ins: [s_1_1: 0.5965100813402789, s_2_1: 0.14210821770124227,
               s_2_2: 0.20944855618709624], outs: [:neuron_l2_1, :neuron_l2_2],
              type: :neuron},
            neuron_l2_2: %{id: :neuron_l2_2,
              ins: [neuron_l1_1: 0.5014907142064751, neuron_l1_2: 0.311326754804393,
               neuron_l1_3: 0.597447524783298], outs: [:a_1], type: :neuron},
            s_1: %{id: :s_1, outs: [:neuron_l1_1, :neuron_l1_2, :neuron_l1_3],
              type: :sensor},
            neuron_l1_1: %{id: :neuron_l1_1,
              ins: [s_1_1: 0.915656206971831, s_2_1: 0.6669572934854013,
               s_2_2: 0.47712105608919275], outs: [:neuron_l2_1, :neuron_l2_2],
              type: :neuron},
            neuron_l2_1: %{id: :neuron_l2_1,
              ins: [neuron_l1_1: 0.4435846174457203, neuron_l1_2: 0.7230402056221108,
               neuron_l1_3: 0.94581636451987], outs: [:a_1], type: :neuron},
            a_1: %{id: :a_1, ins: [:neuron_l2_1, :neuron_l2_2], type: :actuator}]
  end

  test "It should store all nodes as server" do
    assert EXNN.Nodes.names == [:neuron_l1_3,
                                :s_2,
                                :neuron_l1_2,
                                :neuron_l2_2,
                                :s_1,
                                :neuron_l1_1,
                                :neuron_l2_1,
                                :a_1]
  end

end
