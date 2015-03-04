defmodule EXNN.SensorTest do
  use ExUnit.Case

  defmodule TestOut do
    use GenServer

    def state do
      GenServer.call(:test_out, :state)
    end

    def handle_call(:state, _from, state) do
      {:reply, state, state}
    end

    def handle_cast({:signal, message, _}, state) do
      {:noreply, state ++ message}
    end

  end

  defmodule TestSensorX do
    use EXNN.Sensor, with_state: [store: []]

    def initialize(genome) do
      Dict.merge genome, %{store: [value: 2]}
    end

    def sense(sensor, _metadata) do
      { sensor.store[:value] + sensor.store[:extra] }
    end

    def before_sync(sensor) do
      # IO.puts "registered with: #{Process.whereis(self)}"
      new_store = sensor.store ++ [extra: 1]
      %__MODULE__{sensor | store: new_store}
    end

  end

  setup do
    genome = %{id: :my_name, outs: [:test_out]}
    {:ok, pid} = GenServer.start_link(TestOut, [], name: :test_out)
    {:ok, sensor} = TestSensorX.start_link(genome)
    {:ok, []}
  end

  test "it should catch a signal and forward it to it's outs" do
    GenServer.cast :my_name, {:signal, :sync, self}
    :timer.sleep 5
    assert TestOut.state == [my_name_1: 3]
  end

end
