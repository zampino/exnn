defmodule EXNN.Actuator do
  @moduledoc """
    # Actuator data structure

    actuators just receive computed signals
    from neuron of the outer layer

    ### State attributes
    - id: a unique identifier
    - ins: neurons connected to the actuator
    - callback: a callback to process the signal with

    """

  defmacro __using__(options) do
    caller_mod = __CALLER__.module
    custom_state = options[:with_state]||[]
    quote location: :keep do
      use EXNN.NodeServer
      defstruct Keyword.merge unquote(custom_state), [id: nil, ins: []]

      def act(_, _, _) do
        raise "NotImplementedError"
      end

      def notify_fitness(message, metadata) do
        EXNN.Events.Manager.notify :fitness, {message, metadata}
        # :ok = EXNN.Fitness.eval message, metadata
      end

      defimpl EXNN.Connection do
        def signal(actuator, message, metadata) do
          unquote(caller_mod).notify_fitness(message, metadata)
          unquote(caller_mod).act(actuator, message, metadata)
        end
      end

      defoverridable [act: 3]
    end
  end

end
