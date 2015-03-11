defmodule EXNN.Events.Manager do
  use GenEvent

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    # :ok = GenEvent.add_handler(pid, __MODULE__, :ok)
    {:ok, pid}
  end

  def init(:ok) do
    {:ok, %{}}
  end

  # public api

  def notify type, msg do
    GenEvent.ack_notify EXNN.Events.Manager, {type, msg}
  end

  # server callbacks
  # def handle_event({type, msg}, messages) do
  #   messages = Map.update messages, type, [], fn(of_type)->
  #     [msg | of_type]
  #   end
  #   IO.puts "processing events"
  #   {:ok, messages}
  # end

end
