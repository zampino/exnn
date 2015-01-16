defmodule EXNN.Store do

  def start_link(mod) do
    IO.puts "starting store agent with: #{inspect(mod.nodes)}"
    {:ok, pid} = Agent.start_link(fn -> HashDict.new end, name: :exnn_store)
    store_remote_nodes(mod)
    store_pattern(mod)
    {:ok, pid}
  end

  def store_remote_nodes(mod) do
    Agent.update(:exnn_store, &HashDict.put(&1, :remote_nodes, mod.nodes))
  end

  def get_remote_nodes do
    Agent.get(:exnn_store, &HashDict.get(&1, :remote_nodes))
  end

  def store_pattern(mod) do
    Agent.update(:exnn_store, &HashDict.put(&1, :pattern, mod.initial_pattern))
  end

  def get_pattern do
    Agent.get(:exnn_store, &HashDict.get(&1, :pattern))
  end
end
