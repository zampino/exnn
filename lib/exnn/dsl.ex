defmodule EXNN.DSL do

  defmacro extend_struct(struct_mod, keyword) do
    quote do
      defstruct unquote(struct_mod).__struct__
        |> Map.from_struct
        |> Map.to_list
        |> Keyword.merge(unquote(keyword))
    end
  end

  defmacro initial_pattern(pattern) do
    quote do
      # Module.put_attribute(__MODULE__, :init_pattern, unquote(pattern))
      @initial_pattern unquote(pattern)
    end
  end

  defmacro sensor(name, mod, options\\[]) do
    quote do
      @nodes {:sensor, unquote(name), unquote(mod), unquote(options)}
    end
  end

  defmacro actuator(name, mod, options\\[]) do
    quote do
      @nodes {:actuator, unquote(name), unquote(mod), unquote(options)}
    end
  end

  defmacro fitness(mod, options\\[]) do
    quote do
      @fitness {unquote(mod), unquote(options)}
    end
  end

  defmacro __before_compile__(env) do
    nodes = Module.get_attribute(env.module, :nodes)
      |> Macro.escape
    pattern = Module.get_attribute(env.module, :initial_pattern)
      |> Macro.escape
    fitness = Module.get_attribute(env.module, :fitness)

    quote do
      def initial_pattern do
        unquote pattern
      end

      def nodes do
        unquote nodes
      end

      def fitness do
        unquote fitness
      end
    end
  end

end
