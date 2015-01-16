defmodule EXNN.NeuronTest do
  use ExUnit.Case

  defmodule TestServer do
    use GenServer

    def handle_cast({:signal, {origin, value}}, state) do
      state = [{origin, value} | state]
      {:noreply, state}
    end

    def handle_call(:state, _from, state) do
      IO.puts "current state: #{inspect(state)}"
      {:reply, state, state}
    end
  end

  setup do
    {:ok, _pid} = GenServer.start_link(TestServer, [], name: :test_server)
    {:ok, %{}}
  end

  def setup_neuron(ins, trigger) do
    %EXNN.Neuron{
      id: :me,
      ins: ins,
      trigger: trigger,
      outs: [:test_server],
      bias: 1,
      activation: &EXNN.Math.id/1
    }
  end

  test "#impulse" do
    n = setup_neuron([a: 1, b: 2, c: 3], [c: 1, a: 0, b: 2])
    assert EXNN.Neuron.impulse(n) == 8
  end

  test "Connection.signal implemntation"  do
    neuron = setup_neuron([a: 1, b: 2, c: 3], [c: 1])
    neuron = EXNN.Connection.signal(neuron, {:b, 2})
    state = GenServer.call(:test_server, :state)
    assert state == []
    neuron = EXNN.Connection.signal(neuron, {:a, 1})
    assert neuron.trigger == []
    state = GenServer.call(:test_server, :state)
    assert state == [me: 9]
  end

end
