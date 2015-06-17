defmodule EXNN.Utils.Logger do
  # defmacro __using__(_opts) do
  #   quote location: :keep do
  #   end
  # end
  require Elixir.Logger, as: Logger

  def log(head, inspected, level\\:warn) do
    apply(Logger, :log, [level, "#{head}\n#{inspect inspected}"])
  end
end
