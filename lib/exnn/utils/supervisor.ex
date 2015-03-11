defmodule EXNN.Utils.Supervisor do
  defmacro __using__(opts) do
    quote do

      def child(previous, mod, type\\:worker, args, options\\[]) do
        _worker = worker_for(type, mod, args, options)
        previous ++ [_worker]
      end

      def worker_for(:worker, mod, args, options) do
        worker(mod, args)
      end

      def worker_for(:supervisor, mod, args, options) do
        supervisor(mod, args)
      end

    end
  end
end
