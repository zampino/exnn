defmodule EXNN.ActuatorTest do
  use ExUnit.Case, async: true

  defmodule TestAct do
    use EXNN.Actuator, state: [store: []]

    def act(actuator, message, _) do
     %{actuator | store: actuator.store ++ message}
    end
  end

  defmodule TestActTwo do
    use EXNN.Actuator, state: [store: []]

    def initialize(genome) do
      Dict.merge genome, %{store: [init: 'state']}
    end

    def act(actuator, message, _) do
     %{actuator | store: message ++ actuator.store}
    end

    def store do
      GenServer.call(:my_name, :get_store)
    end

    # server extra callbacks
    def handle_call(:get_store, _from, state) do
      {:reply, state.store, state}
    end
  end

  setup do
    genome = %{id: :my_name, ins: [:a, :b]}
    {:ok, pid} = TestActTwo.start_link(genome)

    {_, events_pid} = GenEvent.start_link name: EXNN.Events.Manager
    on_exit fn ->
      if is_pid(events_pid) and Process.alive?(events_pid) do
        Process.exit events_pid, :kill
      end
    end

    {:ok, [genome: genome, server: pid]}
  end

  test 'it should implement the Connetion protocol based on the act method, aliasing current base module is local', %{genome: genome} do

    actuator = struct(TestAct, genome)
    actuator = EXNN.Connection.signal(actuator, [origin: "valuex"], nil)
    assert actuator.store == [origin: "valuex"]

    actuator_2 = struct(TestActTwo, genome)
    actuator_2 = EXNN.Connection.signal(actuator_2, [origin: "value"], nil)
    assert actuator_2.store == [origin: "value"]
  end

  test 'it should implement the nodeserver behaviour' do
    EXNN.NodeServer.forward(:my_name, [self: 101], [])
    :timer.sleep 100
    store = TestActTwo.store
    assert store[:self] == 101
    assert store[:init] == 'state'
  end

end
