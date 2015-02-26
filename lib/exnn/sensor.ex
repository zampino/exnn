defmodule EXNN.Sensor do

  @moduledoc """
    #Sensor Data Structure

    A sensor receives a signal from the outside world
    and broadcasts it to the neuron of the front layer

    ### Attributes
    - id: primary id
    - outs: neuron of the first layer
    - transform: the transformation function
  """

  defmacro __using__(options) do
    state_keyword = options[:with_state] || []
    quote do
      use EXNN.NodeServer
      alias __MODULE__, as: CurrentSensorBase

      defstruct unquote(Keyword.merge state_keyword, [id: nil, outs: []])

      def sync(sensor, origin_value) do
        sensor = before_sync(sensor)
        impulse = format_impulse(sensor, origin_value)
        IO.puts "++++++ sensor impulse: #{inspect(impulse)} to: #{inspect(sensor.outs)} +++++"
        forward = fn(out_id) ->
          GenServer.cast out_id, {:signal, impulse}
        end
        sensor.outs |> Enum.each(forward)
        sensor
      end

      def before_sync(sensor), do: sensor

      # format
      def format_impulse(sensor, origin_value) do
        # TODO: multidimensional sense
        #
        # iterator = fn(x, {list, index})->
        #   step = {:"#{sensor.id}_#{index}", x}
        #   {[step | list], index + 1}
        # end
        #
        # {list, num} = tuple
        # |> Tuple.to_list
        # |> Enum.foldl({[], 0}, iterator)
        #
        # list

        {sensor.id, sense(sensor, origin_value)}
      end

      defimpl EXNN.Connection, for: __MODULE__ do
        def signal(sensor, origin_value) do
          CurrentSensorBase.sync(sensor, origin_value)
        end
      end

      defoverridable [before_sync: 1]
    end
  end

end
