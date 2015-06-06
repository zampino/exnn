defmodule EXNN.Genome do
  defstruct id: nil, type: nil, ins: [], outs: []

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

  def set_ins(genomes, in_ids, dimensions\\nil) do
    Enum.map genomes, &set_ins(&1.type, &1, in_ids, dimensions)
  end

  def set_ins(:neuron, genome, in_ids, dimensions) do
    in_ids = inflate_ins(in_ids, dimensions)

    with_random_weight = fn in_id ->
      {in_id, :random.uniform}
    end
    ins = Enum.map in_ids, with_random_weight
    Map.merge genome, %{ins: ins}
  end

  def set_ins(:actuator, genome, in_ids, _) do
    Map.merge genome, %{ins: in_ids}
  end

  def inflate_ins(in_ids, dimensions) do
    inflate = fn(id, dim) ->
      (1..dim) |> Enum.map(&(:"#{id}_#{&1}"))
    end
    map_id = fn(in_id) ->
      if dim = dimensions[in_id] do
        inflate.(in_id, dim)
      else
        in_id
      end
    end

    in_ids
    |> Enum.map(map_id)
    |> List.flatten()
  end
end
