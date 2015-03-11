defmodule EXNN.Fitness.Starter do

  def start_link do
    {fitness_mod, _} = EXNN.Config.get_fitness
    if fitness_mod == nil do
      {:ok, self}
    else
      :ok = GenEvent.add_handler(EXNN.Events.Manager, EXNN.Events.Manager, :ok)
      {:ok, _pid} = apply fitness_mod, :start_link, []
    end
  end
end
