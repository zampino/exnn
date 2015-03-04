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
    state_keyword = options[:with_state] || []
    quote(location: :keep) do
      alias __MODULE__, as: CurrentActuatorBase

      use EXNN.NodeServer

      defstruct unquote(Keyword.merge state_keyword, [id: nil, ins: []])

      defimpl EXNN.Connection, for: CurrentActuatorBase do
        def signal(actuator, message, _metadata) do
          # notify_dispatcher_with(message, metadata)
          CurrentActuatorBase.act(actuator, message)
        end
      end

    end
  end

end
