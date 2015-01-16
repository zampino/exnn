defmodule EXNN.Application do
  defmacro __using__(opts) do
    quote do
      unquote import_dsl()
      use Application
    end
  end

  defp import_dsl do
    quote location: :keep do
      Module.register_attribute(__MODULE__, :nodes, accumulate: true)
      import EXNN.DSL
      @before_compile EXNN.Application
    end
  end

  defmacro __before_compile__(env) do
    _nodes = Module.get_attribute(env.module, :nodes)
    _nodes = Macro.escape _nodes
    _pattern = Module.get_attribute(env.module, :initial_pattern)
    IO.puts "before compiling I have: #{inspect(_nodes)}"
    quote do
      def initial_pattern do
        unquote _pattern
      end

      def nodes do
        unquote _nodes
      end
    end
  end

end
