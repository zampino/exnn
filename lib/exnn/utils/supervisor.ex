defmodule EXNN.Utils.Supervisor do
  defmacro __using__(_) do
    quote do

      def child(previous, mod, type\\:worker, args, options\\[]) do
        previous ++ [worker_for(type, mod, args, options)]
      end

      def worker_for(:worker, mod, args, options) do
        worker(mod, args, options)
      end

      def worker_for(:supervisor, mod, args, options) do
        supervisor(mod, args, options)
      end

    end
  end
end
