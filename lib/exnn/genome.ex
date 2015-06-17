defmodule EXNN.Genome do
  @moduledoc """
    # EXNN.Genome

    a genome is the basic information
    a cell cares about
    it will specialized once injected into a Specific NodeServer
    where it will drop the type.

    On the contrary
  """

  # NOTE: struct is only used in update operations
  defstruct id: nil, type: nil, ins: [], outs: [], bias: 0, activation: nil

  alias EXNN.Utils.Random
  alias EXNN.Utils.Math

  def collect(type, ids) do
    ids |> Enum.map &build(type, &1)
  end

  def build(:neuron, id) do
    %{type: :neuron, id: id, bias: random_bias, activation: &Math.sin(&1)}
  end

  def random_bias, do: Math.pi * Random.uniform

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
      {in_id, Random.uniform}
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
