defmodule EXNN.Utils.Supervisor do
  defmacro __using__(opts) do
    quote do

      def child(previous, mod, type\\:worker, args) do
        _worker = worker_for(type, mod, args)
        previous ++ [_worker]
      end

      def worker_for(:worker, mod, args) do
        worker(mod, args)
      end

      def worker_for(:supervisor, mod, args) do
        supervisor(mod, args)
      end

    end
  end
end
