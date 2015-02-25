defmodule EXNN.NodeSupervisor do
  use Supervisor

  defmodule Forwarder do
    def start_link(server, genome) do
      IO.puts "forwarder called with: #{inspect(server)} and #{inspect(genome)}"
      server.start_link(genome)
    end
  end

  def start_link do
    Supervisor.start_link __MODULE__, :ok, name: __MODULE__
  end

  def start_node(genome) do
    server = server_for(genome.type, genome.id)
    Supervisor.start_child(__MODULE__, [server, genome])
  end

  def server_for(:neuron, _id) do
    EXNN.Neuron
  end

  def server_for(_type, id) do
    EXNN.Config.config_for(id).mod
  end

  def init(:ok) do
    children = [worker(Forwarder, [], restart: :temporary)]
    supervise(children, strategy: :simple_one_for_one)
  end

end
