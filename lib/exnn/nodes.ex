defmodule EXNN.Nodes do
  require Logger
  use GenServer, async: true

  def start_link do
    GenServer.start_link(__MODULE__,
                        :ok,
                        name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{refs: HashDict.new, names: HashDict.new}}
  end

  # client api

  def register(genome) do
    GenServer.call __MODULE__, {:register, genome}
  end

  def node_pid(id) do
    GenServer.call __MODULE__, {:pids, id}
  end

  def names do
    GenServer.call __MODULE__, :names
  end
  # Server callbacks

  def handle_call({:register, genome}, _from, state) do
    if HashDict.get(state.names, genome.id) do
      {:noreply, state}
    else
      {:ok, pid} = EXNN.NodeSupervisor.start_node(genome)
      ref = Process.monitor(pid)
      refs = HashDict.put state.refs, ref, genome.id
      names = HashDict.put state.names, genome.id, pid
      {:reply, :ok, %{state | refs: refs, names: names}}
    end
  end

  def handle_call(:names, _from, state) do
    {:reply, Dict.keys(state.names), state}
  end

  def handle_call({:pids, id}, _from, state) do
    {:reply, state.names[id], state}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    {name, refs} = HashDict.pop(state.refs, ref)
    Logger.info "[EXNN.Nodes] - DOWN - node: #{name} went down with reason: #{inspect reason}"
    names = HashDict.delete(state.names, name)
    # TODO: reload the node from current connectome
    # genome = EXNN.Connectome.at name
    # {refs, names} = start_node(genome, refs, names)
    {:noreply, %{state | names: names, refs: refs}}
  end

  def handle_info(msg, state) do
    IO.puts "Nodes receives: #{inspect(msg)}"
    {:noreply, state}
  end

end
