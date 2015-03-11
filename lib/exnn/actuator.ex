defmodule EXNN.Actuator do
  @moduledoc """
    # Actuator data structure

      actuators just receive computed signals
      from neuron of the last layer

    ### attributes
    - id: a unique identifier
    - ins: neurons connected to the actuator
    - callback: a callback to process the signal with

    """

  defmacro __using__(options) do
    quote bind_quoted: [state: (options[:with_state] || [])] do
      alias __MODULE__, as: CurrentActuatorBase

      use EXNN.NodeServer

      defstruct Keyword.merge state, [id: nil, ins: []]

      def notify_fitness(message, metadata) do
        
      end

      defimpl EXNN.Connection, for: CurrentActuatorBase do
        def signal(actuator, message, metadata) do
          # CurrentActuatorBase.notify_fitness(message, metadata)
          CurrentActuatorBase.act(actuator, message, metadata)
        end
      end

    end
  end

end
