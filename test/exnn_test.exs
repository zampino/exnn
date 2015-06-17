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
    genomes = EXNN.Connectome.all
    assert length(genomes) == 8
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
