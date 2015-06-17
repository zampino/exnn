defmodule EXNN.Trainer do
  def start do
    # here the trainer FSM enters training mode
    EXNN.Trainer.Sync.sync
  end
end
