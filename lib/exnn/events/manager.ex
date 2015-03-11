defmodule EXNN.Events.Manager do
  use GenEvent

  def start_link do
    GenEvent.start_link(name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  # public api

  def notify type, msg do
    GenEvent.ack_notify EXNN.Events.Manager, {type, msg}
  end

  # server callbacks
  def handle_event({:fitness, {message, metadata}}, messages) do
    :ok = EXNN.Fitness.eval message, metadata
    {:ok, messages}
  end

  def handle_event(_event, messages) do
    {:ok, messages}
  end


end
