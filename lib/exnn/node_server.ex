defmodule EXNN.NodeServer do

  defmacro __using__(options) do
    quote do
      use GenServer

      def start_link(connectable) do
        GenServer.start_link(__MODULE__, connectable, name: connectable.id)
      end

      def handle_cast({:signal, {origin, value}}, connectable) do
        connectable = Connection.signal(connectable, {origin, value})
        {:noreply, connectable}
      end
    end
  end
end
