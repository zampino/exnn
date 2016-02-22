defmodule EXNN.Events.Manager do
  use GenEvent
  require Logger

  def start_link do
    GenEvent.start_link(name: __MODULE__)
  end

  def init(:ok) do
    {:ok, nil}
  end

  # PUBLIC CLIENT API

  def notify type, msg do
    GenEvent.ack_notify EXNN.Events.Manager, {type, msg}
  end

  # SERVER CALLBACKS

  def handle_event {:fitness, {message, metadata}}, state do
    Logger.debug "[EXNN.Events.Manager] -- handle :fitness event message #{inspect message} - meta: #{inspect metadata}"
    :ok = EXNN.Fitness.eval message, metadata
    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

end
