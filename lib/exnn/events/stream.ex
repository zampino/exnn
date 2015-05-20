defmodule EXNN.Events.Stream do
  def start_link do
    IO.puts "starting stream"
    Task.start_link __MODULE__, :run, []
  end

  def run do
    GenEvent.stream(EXNN.Events.Manager)
    |> Stream.each(&dispatch(&1))
    |> Stream.run
    # notify someone that the event stream has started
  end

  def dispatch({:info, {from, msg}}) do
    send from, "received #{msg}"
  end

  # def dispatch({:fitness, {message, meta}}) do
  #   # :ok = EXNN.Fitness.eval(message, meta)
  # end

  def dispatch({_, msg}) do
    # IO.puts "dispatching event #{inspect(msg)}"
    :ok
  end
end
