defmodule EXNN.Cortex do
  use GenServer

  def start_link do
    {:ok, pid} = GenServer.start_link __MODULE__, :ok, name: :exnn_cortex
    GenServer.cast pid, :register
    {:ok, pid}
  end

  def init(:ok) do
    Agent.get :exnn_connectome, &(HashDict.keys(&1))
  end

  def start_server(genome) do
    server_for(genome.type, genome.id).start_link(genome)
  end

  def server_for(:neuron, _id) do
    EXNN.Neuron
  end

  def server_for(type, id) do
    EXNN.Store.get_remote_nodes
    |> Enum.find_value(fn(t, i, mod)-> id == i and mod end)
  end

  def monitor({:ok, pid}) do
    Process.monitor(pid)
  end

  def register(genome) do
    genome
    |> start_server
    |> monitor
  end

  # server impl

  def handle_cast(:ready) do
    IO.puts "ready"
  end

  def handle_cast(:register, []) do
    GenServer.cast(:exnn_cortex, :ready)
    {:noreply, []}
  end

  def handle_cast(:register, [id | rest]) do
    Agent.get(:exnn_connectome, &(HashDict.get(&1, id)))
    |> register
    {:noreply, [rest]}
  end

end
