defmodule EXNN.NodeServer do
  # public api

  # TODO: maybe import some API module in the quote below
  @doc "process and forward message"
  def forward(id, message, metadata) do
    GenServer.call(id, {:forward, message, metadata})
  end

  @doc "injects partial genome into node."
  def patch(id, partial) do
    GenServer.call(id, {:patch, partial})
  end

  @doc "dumps current genome to Connectome"
  def dump(id) do
    GenServer.call(id, :dump)
  end

  defmacro __using__(options) do
    quote do
      use GenServer
      import EXNN.Utils.Logger

      def start_link(genome) do
        GenServer.start_link(__MODULE__, genome, name: genome.id)
      end

      def init(genome) do
        {:ok, struct(__MODULE__, initialize(genome))}
      end

      def initialize(genome), do: genome

      # server callbacks
      @doc "NodeServer basic protocol action is to react to
        a :forward event.
            message is a keyword [origin: value]"
      def handle_call({:forward, message, metadata}, _from, connectable) do
        {:reply, :ok, EXNN.Connection.signal(connectable, message, metadata)}
      end

      # TODO: move to neuron 
      def handle_call({:patch, fun}, _from, node) do
        state = Map.merge(node, fun.(node))
        destruct = Map.from_struct state
        {:reply, destruct, state}
      end

      def handle_call(:dump, _from, node) do
        {:reply, node, node}
      end

      defoverridable [initialize: 1]
    end
  end
end
