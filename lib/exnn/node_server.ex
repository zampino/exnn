defmodule EXNN.NodeServer do
  defmacro __using__(options) do
    quote do
      use GenServer

      def start_link(genome) do
        GenServer.start_link(__MODULE__, genome, name: genome.id)
      end

      def init(genome) do
        {:ok, struct(__MODULE__, initialize(genome))}
      end

      def initialize(genome), do: genome

      @doc "NodeServer basic protocol action is to react to
            a :signal event.
            message is a keyword [origin: value]

      "
      def handle_cast({:signal, message, metadata}, connectable) do
        connectable = EXNN.Connection.signal(connectable, message, metadata)
        {:noreply, connectable}
      end

      defoverridable [initialize: 1]
    end
  end
end
