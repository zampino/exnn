defmodule EXNN.NeuronTest do
  use ExUnit.Case

  defmodule TestServer do
    use GenServer

    def handle_call({:forward, message, _}, _from, state) do
      {:reply, :ok, state ++ message}
    end

    def handle_call(:state, _from, state) do
      {:reply, state, state}
    end
  end

  setup do
    {:ok, pid_1} = GenServer.start_link(TestServer, [], name: :test_server_1)
    {:ok, pid_2} = GenServer.start_link(TestServer, [], name: :test_server_2)

    on_exit fn ->
      IO.puts "This is invoked once the test is done"
      [pid_1, pid_2] |> Enum.each &(Process.exit &1, :kill)
    end

    {:ok, []}
  end

  def setup_neuron(ins, trigger, acc) do
    %EXNN.Neuron{
      id: :me,
      ins: ins,
      acc: acc,
      trigger: trigger,
      outs: [:test_server_1, :test_server_2],
      bias: 0,
      activation: &EXNN.Math.id/1
    }
  end

  test "#impulse" do
    n = setup_neuron([a: 1, b: 2, c: 3], [], [c: 1, a: 2, a: 1, b: 3, b: 4])
    {neuron, value} = EXNN.Neuron.impulse(n)
    assert value  == 11
    assert neuron.acc == [a: 1, b: 4]
  end

  test "Neuron.signal implemntation" do
    neuron = setup_neuron([a: 1, b: 1, c: 1], [:b, :a], [c: 7, a: 6, c: 1])

    state_1 = GenServer.call(:test_server_1, :state)
    state_2 = GenServer.call(:test_server_2, :state)

    assert state_1 == []
    assert state_2 == []

    neuron = EXNN.Neuron.signal(neuron, [b: 2], [])
    state_1 = GenServer.call(:test_server_1, :state)
    state_2 = GenServer.call(:test_server_2, :state)
    assert state_1 == []
    assert state_2 == state_1
    assert neuron.trigger == [:a]
    assert neuron.acc == [c: 7, a: 6, c: 1, b: 2]

    neuron = EXNN.Neuron.signal(neuron, [a: 2], [])
    state_1 = GenServer.call(:test_server_1, :state)
    state_2 = GenServer.call(:test_server_2, :state)
    assert state_1 == [me: 15] # 6 + 2 + 7
    assert state_2 == state_1
    assert neuron.trigger == [:a, :b, :c]
    assert neuron.acc == [c: 1, a: 2]

    neuron = EXNN.Neuron.signal(neuron, [c: 1], [])
    state_1 = GenServer.call(:test_server_1, :state)
    state_2 = GenServer.call(:test_server_2, :state)
    assert state_1 == [me: 15]
    assert state_2 == state_1
    assert neuron.trigger == [:a, :b]
    assert neuron.acc == [c: 1, a: 2, c: 1]
  end


  test "starting a neuron server" do
    genome = %{
      id: :my_name,
      ins: [a: 3, b: 2, c: 1],
      outs: [:test_server_1, :test_server_2],
      bias: 0,
      activation: &EXNN.Math.id/1
    }
    {:ok, _pid} = EXNN.Neuron.start_link(genome)
    # :timer.sleep 200
    EXNN.NodeServer.forward(:my_name, [c: 3], [])
    EXNN.NodeServer.forward(:my_name, [a: 1], [])
    EXNN.NodeServer.forward(:my_name, [b: 2], [])
    :timer.sleep 100
    state_1 = GenServer.call(:test_server_1, :state)
    state_2 = GenServer.call(:test_server_2, :state)
    assert state_1 == [my_name: 10] # 3 + 4 + 3
    assert state_2 == state_1
  end

end
