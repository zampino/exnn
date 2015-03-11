defmodule EXNN.Trainer.Sync do
  use GenServer

  @train_interval 100

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__,
      :ok,
      name: __MODULE__)
    {:ok, pid}
  end

  def init(:ok) do
    stream = Stream.repeatedly(&train/0)
    {:ok, %{stream: stream}}
  end

  def train do
    # IO.puts "^^^^^^^^^ TRAINING ^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    EXNN.Config.sensors |> Enum.each(&train/1)
  end

  def train(sensor_id) do
    EXNN.NodeServer.forward(sensor_id, :sync, self)
  end

  # public api
  def iterate(cycles) do
    GenServer.call __MODULE__, {:iterate, cycles}
  end

  # server callbacks
  def handle_call({:iterate, num}, _from, state) do
    ^num = Enum.take(state.stream, num) |> length()
    {:reply, :ok, state}
  end
end
