defmodule EXNN.Strategies.TrainerStrategyBuilder do

  def define_module(app, mode, options) do
    quote do
      defmodule Module.concat(unquote(app), EXNN.Trainer.Sync.Strategy) do
        @defaults %{
          max_attempts: 3000,
          max_reverts: 75,
          tolerance: 0.1,
          reporter: :logger
        }
        import EXNN.Strategies.TrainerStrategyBuilder,
          only: [impl_for: 2]
        IO.puts "what the hell is #{inspect {__MODULE__, unquote(mode)}}"

        impl_for unquote(mode), unquote(options)
      end
    end
  end

  defmacro impl_for(:static, options) do
    quote do

      def init do
        @defaults
        |> Map.merge(Map.new(unquote options))
      end

      def fitter(state) do
        :gen_fsm.send_event EXNN.Trainer.Sync, :fit
        state
      end
    end
  end

  defmacro impl_for(:continuous, options) do
    quote do
      def init do
        @defaults
        |> Map.merge(%{stable_after: 20})
        |> Map.merge(Map.new(unquote options))
      end

      def fitter(state) do
        %{
          stability_count: count,
          stable_after: limit
        } = state
        if count >= limit do
          :gen_fsm.send_event EXNN.Trainer.Sync, :fit
        end
        %{ state | stability_count: count + 1 }
      end
    end
  end

  defmacro impl_for(whatever, options) do
    IO.puts "//// SOMETHING WRONG ///: #{inspect {whatever, options}}"
  end

end
