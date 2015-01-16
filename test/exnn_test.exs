defmodule EXNNTest do
  use ExUnit.Case

  # test "build NN from pattern" do
  #
  # end


  # sketch host application

  defmodule HostApp do
    use EXNN.Application

    set_initial_pattern [
      sensor: [:s_1, :s_2],
      neuron: {3, 2},
      actuator: [:a_1, :a_2]
    ]

    set_sensor :s_1, HostApp.SensOne, dim: 1
    set_sensor :s_2, HostApp.SensTwo, dim: 1
    set_actuator :a_1, HostApp.Recorder

    def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        # Define workers and child supervisors to be supervised
        # worker(HostApp.Worker, [arg1, arg2, arg3])
        supervisor(EXNN.Supervisor, [[config: __MODULE__]])
      ]

      opts = [strategy: :one_for_one, name: HostApp.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end

  setup do
    {:ok, pid} = HostApp.start(:normal, [])# Application.start(HostApp)
    {:ok, [supervisor: pid]}
  end

  test "initial_pattern" do
    assert HostApp.nodes == [{:actuator, :a_1, HostApp.ActOne}, {:sensor, :s_2, HostApp.SensTwo}, {:sensor, :s_1, HostApp.SensOne}]

    assert HostApp.initial_pattern == [sensor: [:s_1, :s_2],
      neuron: {3, 2},
      actuator: [:a_1, :a_2]
    ]
  end

  test "storing remote nodes and pattern in the store agent" do
    assert EXNN.Store.get_remote_nodes == [
      {:actuator, :a_1, EXNNTest.HostApp.ActOne},
      {:sensor, :s_2, EXNNTest.HostApp.SensTwo, [dim: 1]},
      {:sensor, :s_1, EXNNTest.HostApp.SensOne, [dim: 1]}
    ]

    assert EXNN.Store.get_pattern == [sensor: [:s_1, :s_2], neuron: {3, 2}, actuator: [:a_1, :a_2]]
  end

  test "storing genomes" do
    IO.puts "casting"
    origin = self
    Agent.cast :exnn_connectome, &(send(origin, HashDict.to_list(&1)))

    assert_receive [neuron_l1_3: %{id: :neuron_l1_3, ins: [s_1: 0.14210821770124227, s_2: 0.20944855618709624], outs: [:neuron_l2_1, :neuron_l2_2], type: :neuron}, s_2: %{id: :s_2, type: :sensor}, neuron_l1_2: %{id: :neuron_l1_2, ins: [s_1: 0.47712105608919275, s_2: 0.5965100813402789], outs: [:neuron_l2_1, :neuron_l2_2],
     type: :neuron}, neuron_l2_2: %{id: :neuron_l2_2, ins: [neuron_l1_1: 0.5014907142064751, neuron_l1_2: 0.311326754804393, neuron_l1_3: 0.597447524783298], outs: [:a_1, :a_2], type: :neuron}, a_2: %{id: :a_2, ins: [:neuron_l2_1, :neuron_l2_2], type: :actuator}, s_1: %{id: :s_1, type: :sensor}, neuron_l1_1: %{id: :neuron_l1_1, ins: [s_1: 0.915656206971831, s_2: 0.6669572934854013], outs: [:neuron_l2_1, :neuron_l2_2], type: :neuron}, neuron_l2_1: %{id: :neuron_l2_1, ins: [neuron_l1_1: 0.4435846174457203, neuron_l1_2: 0.7230402056221108, neuron_l1_3: 0.94581636451987], outs: [:a_1, :a_2], type: :neuron}, a_1: %{id: :a_1, ins: [:neuron_l2_1, :neuron_l2_2], type: :actuator}]
  end

end

defmodule EXNNTest.HostApp.Recorder do
  use EXNN.Actuator

  def init(state) do
    Map.put(state, :store, [])
  end

  def act(state, {from, signal}) do
    store = [{from, signal} | state.store]
    Map.update(state, store: store)
  end
end

defmodule EXNNTest.HostApp.SensOne do
  use EXNN.Sensor

  def sense(_sensor, _meta) do
    # { 0.1 }
    0.1
  end
end

defmodule EXNNTest.HostApp.SensTwo do
  use EXNN.Sensor

  def sense(_sensor, _meta) do
    # { 0.9 }
    0.9
  end
end
