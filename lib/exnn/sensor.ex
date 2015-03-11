defmodule EXNN.Sensor do

  @moduledoc """
    # Sensor Server Protocol

    Modules using EXNN.Sensor are turned into Sensor Servers

    Sensor modules *MUST* implement either
    a sense/2 function emitting an enumerable containing impulses
    of a compatible dimension,
    or a sync/2 function which returns sensor.
    Both functions take (sensor, {origin, :sync}) as arguments.

    A sensor has a forward(sensor, value) function available.
    In case we want to change a sensor's state during sync, we
    can override a before_synch(sensor) function in case we
    don't overridde the sync function.

    They share the underlying genome as state, which can
    be merged with custom attributes and default values
    passign a with_state option to the use macro.

    A sensor receives or propagates a signal from the outside world
    and broadcasts it to the neuron of the front layer.

    ## State Attributes
    - id: primary id
    - outs: neuron of the first layer
  """

  defmacro __using__(options) do
    state_keyword = options[:with_state] || []
    quote do
      use EXNN.NodeServer
      alias __MODULE__, as: CurrentSensorBase

      defstruct unquote(Keyword.merge state_keyword, [id: nil, outs: []])

      @doc "#sense must be implemented in the sensor implementation"
      def sync(sensor, metadata) do
        sensor = before_sync(sensor)
        forward(sensor, sense(sensor, metadata))
      end

      def sense(_, _) do
        raise "NotImplementedError"
      end

      def forward(sensor, value) do
        spread_value = format_impulse(sensor, value)
        cast_out = fn(out_id) ->
          EXNN.NodeServer.forward(out_id, spread_value, [{sensor.id, value}])
        end
        :ok = sensor.outs |> Enum.each(cast_out)
        sensor
      end

      def before_sync(sensor), do: sensor

      @doc "value must be an enumerable compatible with the
            dimension of the sensor"
      def format_impulse(sensor, tuple) do
        sensor_id = sensor.id
        iterator = fn(val, {list, index})->
          step = {:"#{sensor_id}_#{index}", val}
          {[step | list], index + 1}
        end
        {list, num} = tuple
        |> Tuple.to_list
        |> List.foldl({[], 1}, iterator)
        list
      end

      defimpl EXNN.Connection, for: __MODULE__ do
        def signal(sensor, :sync, metadata) do
          CurrentSensorBase.sync(sensor, metadata)
        end
      end

      defoverridable [before_sync: 1, sync: 2, sense: 2]
    end
  end

end
