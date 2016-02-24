defmodule EXNN.Trainer do
  @moduledoc ~S(
    training API
  )

  @doc """
    ```elixir
      EXNN.Trainer.start tolerance: 0.01, stability_count: 10
    ```

    Starts the trainer and hit sensors for sync round.

  """
  def start(options \\ []) do
    # here the trainer FSM enters training mode
    EXNN.Trainer.Sync.start Map.new(options)
  end
end
