defmodule EXNN.Strategies do
  require Logger

  @spec train_with(Keyword.t) :: Code.t
  defmacro train_with(options) do
    IO.puts "TRAIN_WITH #{inspect options}"
    quote do
      @training_options unquote(options)
    end
  end

  def runtime_strategy(app, module, method, args) do
    try do
      module = strategy_for(app, module)
      res = Kernel.apply(module, method, args)
      res
    catch
      :error, value ->
        stack = System.stacktrace()
        exception = Exception.normalize(:error, value, stack)
        Logger.error "[#{__MODULE__}] #{inspect exception} \n #{inspect stack}"
    end
  end

  defp strategy_for(app, module) do
    app
    |> Module.concat(module)
    |> Module.concat(Strategy)
  end

  defmacro __before_compile__(env) do
    options = Module.get_attribute(env.module, :training_options) || []
    {mode, options} = Keyword.pop options, :mode, :static
    IO.puts "\n STRATEGies) I can see #{inspect {mode, options}} >>\n"

    # quote do: unquote
    EXNN.Strategies.TrainerStrategyBuilder.define_module(env.module, mode, options)
    # EXNN.Strategies.WhateverStrategyBuilder.define_module_from(env.module, mode, options)
  end

end
