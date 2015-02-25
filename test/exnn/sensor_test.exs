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

    def handle_cast({:signal, {origin, value}}, state) do
      {:noreply, [{origin, value} | state]}
    end

  end

  defmodule TestSensorX do
    use EXNN.Sensor, with_state: [store: []]

    def initialize(genome) do
      Dict.merge genome, %{store: [value: 2]}
    end

    def sense(sensor, {pid, :sync}) do
      sensor.store[:value] + sensor.store[:extra]
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
    GenServer.cast :my_name, {:signal, {self, :sync}}
    :timer.sleep 1
    assert TestOut.state == [my_name: 3]
  end

end
