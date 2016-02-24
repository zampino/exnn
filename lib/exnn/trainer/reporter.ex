defmodule EXNN.Trainer.Reporter do
  require Logger

  def dump(state) do
    report_to state.reporter, state
  end

  defp report_to :logger, state do
    Logger.info format(state)
  end

  defp report_to {:file, _path}, _state do
    raise "NotImplemented"
  end

  defp report_to(name, state) when is_atom(name) or is_pid(name) do
    send name, {:report, state}
  end

  defp format(state) do
    "[EXNN.Trainer.Reporter] - Trainer reached stable fitness #{state.fitness} in #{state.fit_after} ms "
  end
end
