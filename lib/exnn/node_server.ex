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

      def handle_cast({:signal, {origin, value}}, connectable) do
        connectable = EXNN.Connection.signal(connectable, {origin, value})
        {:noreply, connectable}
      end

      defoverridable [initialize: 1]
    end
  end
end
