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

    def handle_call({:forward, message, _}, _from, state) do
      {:reply, :ok, state ++ message}
    end

  end

  defmodule TestSensorX do
    use EXNN.Sensor, state: [store: []]

    def initialize(genome) do
      Dict.merge genome, %{store: [value: 2]}
    end

    def sense(sensor, _metadata) do
      { sensor.store[:value] + sensor.store[:extra] }
    end

    def before_sync(sensor) do
      new_store = sensor.store ++ [extra: 1]
      %__MODULE__{sensor | store: new_store}
    end

  end

  setup do
    genome = %{id: :my_name, outs: [:test_out]}
    {:ok, _pid} = GenServer.start_link(TestOut, [], name: :test_out)
    {:ok, _sensor} = TestSensorX.start_link(genome)
    {:ok, []}
  end

  test "it should catch a signal and forward it to it's outs" do
    EXNN.NodeServer.forward(:my_name, :sync, self)
    :timer.sleep 5
    assert TestOut.state == [my_name_1: 3]
  end

end
