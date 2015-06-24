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
    GenServer.call __MODULE__, {:eval, message, meta}
  end

  defmacro __using__(options \\ []) do
    quote location: :keep do
      use GenServer
      defstruct unquote(options) |> Keyword.get(:state, [])

      def start_link do
        GenServer.start_link(__MODULE__, :ok, name: EXNN.Fitness)
      end

      def init(:ok) do
        {:ok, struct(__MODULE__)}
      end

      # internal api

      def eval(_message, _meta, _state) do
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

      defoverridable [eval: 3]
    end
  end
end
