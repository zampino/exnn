defmodule EXNN.Nodes.Loader do

  def start_link do
    # implement state dump for restarts
    result = Agent.get(EXNN.Connectome, &(&1))
    |> Enum.each(&register/1)
    {result, self}
  end

  def register({id, genome}) do
    EXNN.Nodes.register(genome)
  end

end
