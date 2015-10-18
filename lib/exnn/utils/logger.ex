defmodule EXNN.Utils.Logger do
  # defmacro __using__(_opts) do
  #   quote location: :keep do
  #   end
  # end
  require Elixir.Logger, as: Logger

  defmacro log(head, inspected, level\\:warn) do
    # NOTE: Logger.log/? was removed in Elixir 1.1
    Macro.expand "Logger.#{level} \"#{head}\n#{inspect inspected}\"", __ENV__
  end
end
