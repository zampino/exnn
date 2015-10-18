defmodule EXNN.Actuator do
  @moduledoc """
    # Actuator data structure

    actuators just receives computed signals
    from neuron of the outer layer

    ### State attributes
    - id: a unique identifier
    - ins: neurons connected to the actuator
    - callback: a callback to process the signal with

    """

  defmacro __using__(options \\ []) do
    caller = __CALLER__.module
    quote location: :keep do
      use EXNN.NodeServer
      defstruct unquote(options) |>
        Keyword.get(:state, []) |> Dict.merge([id: nil, ins: []])

      def act(_state, _message, _meta) do
        raise "NotImplementedError"
      end

      def notify_fitness(message, metadata) do
        EXNN.Events.Manager.notify :fitness, {message, metadata}
        # :ok = EXNN.Fitness.eval message, metadata
      end

      defimpl EXNN.Connection do
        def signal(actuator, message, metadata) do
          state = unquote(caller).act(actuator, message, metadata)
          # TODO: pass actuator state to fitness as well
          unquote(caller).notify_fitness(message, metadata)
          state
        end
      end

      defoverridable [act: 3]
    end
  end

end
