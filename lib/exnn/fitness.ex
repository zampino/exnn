defmodule EXNN.Fitness do
  @moduledoc """
    # Fitness Server Interface

    any module using Fitness must configure a trigger
    which states when the system has gathered enough
    information to let the trainer know when it can
    sync again

    ```elixir
      defmodule MyFitness do

      end
    ```
  """

  # PUBLIC CLIENT API

  def eval message, meta do
    GenServer.call EXNN.Fitness, {:eval, message, meta}
  end

  defmacro __using__(options) do
    state = options[:state] || []

    quote(bind_quoted: [
      state: state]) do

      use GenServer
      defstruct Keyword.merge [acc: []], state

      def start_link do # (config) do
        GenServer.start_link(__MODULE__, :ok, name: EXNN.Fitness)
      end

      def init(:ok) do
        state = struct(__MODULE__)
        {:ok, state}
      end

      # internal api

      def eval(_message, _meta) do
        raise "NotImplementedError"
      end

      def emit(value) do
        :ok = EXNN.Trainer.Sync.sync %{fitness: value}
      end

      # server callbacks

      def handle_cast {:eval, message, meta}, state do
        {:noreply, eval(message, meta, state)}
      end

      def handle_call {:eval, message, meta}, _from, state do
        {:reply, :ok, eval(message, meta, state)}
      end

      defoverridable [eval: 2]
    end
  end
end
