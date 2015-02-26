defmodule EXNN.Trainer do
  use GenServer

  @train_interval 200

  def start_link do
    GenServer.start_link(__MODULE__,
      :ok,
      name: __MODULE__)
  end

  def init(:ok) do
    stream = Stream.repeatedly(&train/0)
    {:ok, %{stream: stream}}
  end

  def train do
    EXNN.Config.sensors |> Enum.each(&train/1)
    # :timer.sleep @train_interval
  end

  def train(sensor_id) do
    GenServer.cast sensor_id, {:signal, {self, :sync}}
  end

  # public api
  def iterate(cycles) do
    GenServer.call __MODULE__, {:iterate, cycles}
  end

  # server callbacks
  def handle_call({:iterate, num}, _from, state) do
    report = Stream.take(state.stream, num) |> Stream.run()
    {:reply, report, state}
  end
end
