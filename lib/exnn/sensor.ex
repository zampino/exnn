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

  # defstruct id: nil, outs: [], transform: &EXNN.Math.id/1
  #
  # def new(id, outs) do
  #   struct __MODULE__, [id: id, outs: outs]
  # end
  #
  # def fire!(sensor, value) do
  #   notify = fn out_id ->
  #     GenServer.cast(out_id, {:signal, {sensor.id, value}})
  #   end
  #   sensor.outs |> Enum.each notify
  #   sensor
  # end
  #
  # defimpl EXNN.Connection, for: __MODULE__ do
  #   def signal(sensor, {_, value}) do
  #     EXNN.Sensor.fire!(sensor, value)
  #   end
  # end

  defmacro __using__(options) do
    quote do
      use GenServer # EXNN.NodeServer

      def start_link(sensor) do
        GenServer.start_link(__MODULE__, sensor, name: sensor.id)
      end

      def handle_cast {:sync, meta}, sensor do

        sensor.outs
        |> Enum.each &(GenServer.cast(&1, {:signal, format_impulse(sensor, meta)}))

        {:noreply, sensor}
      end

      # format
      def format_impulse(sensor, meta) do
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

        {sensor.id, sense(sensor, meta)}
      end
    end
  end

end
