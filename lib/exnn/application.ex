defmodule EXNN.Application do
  @moduledoc """
    _Gentle wrapper around OTP Application + DSL importer_

    # Usage

    use it in your main app module

    ```elixir
    defmodule MyApp do
      use EXNN.Application

      [ ... CONFIGURATION DSL ... ]

      def start(_, _) do


      end
    end
    ```

    # Configuration

    * sensor

    * actuator

    * fitness

    * initial_pattern

    * `train_with [options]`


    Allowed options:
      * mode: :continuous | :static (default)
        when `:continuous` mode is given, you have to provide a `:stable_after`
        positive integer value .

      * dump: {:file, path} | :process_name

      * tolerance: float (lower neighbor of 1 in which positives are recorded)
      * stable_after: number of positives after which we call

      * max_reverts: maximum random restarts counts (default 80),
      * max_attempts: overall max epochs (default 2000)),

    Check defatuls in EXNN.Trainer.Sync @defatults

    ###  State Machine

    until  a `start` EXNN.Trainer lays in `idle` status,
    then it enters `learning`. When fitness stably enters
    the tolerance neighborhood of 1 then the status goes into `online`.


  """

  defmacro __using__(_) do
    quote  do
      use Application
      unquote compile_strategies()
      unquote import_dsl()
    end
  end

  defp compile_strategies do
    quote location: :keep do
      import EXNN.Strategies, only: [train_with: 1]
      @before_compile EXNN.Strategies
    end
  end

  defp import_dsl do
    quote location: :keep do
      Module.register_attribute(__MODULE__, :nodes, accumulate: true)
      import EXNN.DSL, only: [
        initial_pattern: 1,
        sensor: 2, sensor: 3,
        actuator: 2, actuator: 3,
        fitness: 1, fitness: 2
      ]
      @before_compile EXNN.DSL
    end
  end
end
