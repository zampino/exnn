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
    quote do
      use EXNN.NodeServer

      defimpl EXNN.Connection, for: __MODULE__ do
        def signal(actuator, {origin, value}) do
          __MODULE__.act.(actuator, {origin, value})
        end
      end

    end
  end

end
