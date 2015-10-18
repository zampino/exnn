defmodule EXNN.Utils.Logger do
  # defmacro __using__(_opts) do
  #   quote location: :keep do
  #   end
  # end

  # defmacro log(head, inspected, level\\:warn) do
    # quote do
    #   require Elixir.Logger, as: Logger
    # end

    # NOTE: Logger.log/? was removed in Elixir 1.1
    # Macro.expand "Logger.#{level} \"#{head}\n#{inspect inspected}\"", __ENV__

    # FIXME: worst choice ever
    # Code.eval_string("Logger.#{level}(\"#{head}\n#{inspect inspected}\")")
  # end
end
