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

  defmacro __using__(options) do
    state = options[:state] || []
    config = options[:config] || []
    quote(bind_quoted: [name: __MODULE__, custom_state: state]) do
      use GenServer

      defstruct Keyword.merge [acc: []], state

      def start_link do
        GenServer.start_link(__MODULE__, config, name: name)
      end

      def init(config) do
        # react on mode = config[:mode]
        # notify trainer of the chosen mode
        {:ok, struct(__MODULE__)}
      end

    end
  end
end
