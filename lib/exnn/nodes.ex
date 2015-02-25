defmodule EXNN.Nodes do
  use GenServer

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
    GenServer.cast __MODULE__, {:register, genome}
  end

  def node_pid(id) do
    GenServer.call __MODULE__, {:pids, id}
  end

  # Server callbacks

  def handle_cast({:register, genome}, state) do
    if HashDict.get(state.names, genome.id) do
      {:noreply, state}
    else
      {:ok, pid} = EXNN.NodeSupervisor.start_node(genome)
      ref = Process.monitor(pid)
      refs = HashDict.put state.refs, ref, genome.id
      names = HashDict.put state.names, genome.id, pid
      {:noreply, %{state | refs: refs, names: names}}
    end
  end

  def handle_call({:pids, id}, _from, state) do
    {:reply, state.names[id], state}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    IO.puts "DOWN with reason: #{inspect(_reason)}"
    {name, refs} = HashDict.pop(state.refs, ref)
    names = HashDict.delete(state.names, name)
    # GenEvent.sync_notify(state.events, {:exit, name, pid})
    {:noreply, %{state | names: names, refs: refs}}
  end

  def handle_info(msg, state) do
    IO.puts "Nodes receives: #{inspect(msg)}"
    {:noreply, state}
  end

end
