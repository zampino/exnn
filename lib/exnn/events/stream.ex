defmodule EXNN.Events.Stream do
  def start_link do
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

  def dispatch({_, msg}) do
    IO.puts "dispatching event #{msg}"
  end
end
