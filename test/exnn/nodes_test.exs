defmodule EXNN.NodesTest do
  use ExUnit.Case, async: true

  setup do #_all do
    {_status, node_sup} = EXNN.NodeSupervisor.start_link
    IO.puts "/////////////////////////////// exnn test node superv tries to start: #{_status}"
    # {:ok, %{sup: node_sup}}

    # on_exit fn ->
    #   Process.exit(node_sup, :normal)
    # end
  # end
  #
  # setup context do
  #  node_sup = context[:sup]

    fake_module = %{
      nodes: [
        {:sensor, :some_id, TestSensor, []},
        {:actuator, :some_other_id, TestSensor, []}
      ],
      initial_pattern: []
    }

    {:ok, config} = EXNN.Config.start_link(fake_module)
    {:ok, nodes} = EXNN.Nodes.start_link

    on_exit fn ->
      Process.exit node_sup, :kill

      [config, nodes]
      |> Enum.each(&Process.exit(&1, :normal))
    end

    Process.register self, :test_pid

    fake_genome = %{id: :some_other_id, message: 'some message', type: :unknown}
    {:ok, [genome: fake_genome]}
  end

  test "I can register a node which will be started and a reference to its pid will
be stored into the server's state", %{genome: genome} do
    EXNN.Nodes.register(genome)
    assert_receive 'some message'
  end

  test "the node is monitored by the Nodes server and if it crashes it won't be
restarted", %{genome: genome} do
    EXNN.Nodes.register(genome)
    :timer.sleep 100

    GenServer.cast genome.id, :unhandled
    :timer.sleep 100

    pid = EXNN.Nodes.node_pid genome.id
    assert pid == nil
  end

end

defmodule TestSensor do
  use GenServer

  def start_link(genome) do
    send :test_pid, genome.message
    GenServer.start_link(__MODULE__, genome, [name: genome.id])
  end

  def handle_cast :foo, state do
    IO.puts "foo!!!"
    {:noreply, state}
  end
end
