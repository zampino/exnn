defmodule EXNN.Genome do

  def collect(type, ids) do
    ids |> Enum.map &build(type, &1)
  end

  def build(type, id) do
    %{type: type, id: id}
  end

  def set_outs(genomes, outs) do
    out_ids = Enum.map outs, &(&1.id)
    Enum.map genomes, fn(g) ->
      Map.merge(g, %{outs: out_ids})
    end
  end

  def set_ins(genomes, in_ids) do
    Enum.map genomes, &set_ins(&1.type, &1, in_ids)
  end

  def set_ins(:neuron, genome, in_ids) do
    with_random_weight = fn in_id ->
      {in_id, :random.uniform}
    end
    ins = Enum.map in_ids, with_random_weight
    Map.merge genome, %{ins: ins}
  end

  def set_ins(:actuator, genome, in_ids) do
    Map.merge genome, %{ins: in_ids}
  end
end
