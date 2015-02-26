defmodule EXNN.NodeSupervisor do
  use Supervisor

  defmodule Forwarder do
    def start_link(genome) do
      server = server_for(genome.type, genome.id)
      server.start_link(genome)
    end

    def server_for(:neuron, _id) do
      EXNN.Neuron
    end

    def server_for(_type, id) do
      EXNN.Config.config_for(id).mod
    end
  end

  def start_link do
    Supervisor.start_link __MODULE__, :ok, name: __MODULE__
  end

  def start_node(genome) do
    Supervisor.start_child(__MODULE__, [genome])
  end

  def init(:ok) do
    children = [worker(Forwarder, [], restart: :temporary)]
    supervise(children, strategy: :simple_one_for_one)
  end

end
