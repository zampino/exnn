defmodule EXNN.Nodes.Loader do

  def start_link do
    result = EXNN.Connectome.all
    |> Enum.each(&register/1)
    {result, self}
  end

  def register(genome) do
    EXNN.Nodes.register(genome)
  end

end
