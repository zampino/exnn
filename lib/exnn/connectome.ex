defmodule EXNN.Connectome do

  @doc "accepts patterns of the form:

    [sensor: N_s, neuron: [l1: N_1, ..., ld: N_d], actuator: N_a]

    where N_s, N_i, N_a are natural numbers.
  "
  def start_link() do
    {:ok, pid} = Agent.start_link(fn() -> HashDict.new end,
      name: :exnn_connectome)

    EXNN.Store.get_pattern
    |> EXNN.Pattern.build_layers
    |> link([])
    |> store

    {:ok, pid}
  end

  def store(collection) when is_list(collection) do
    collection = List.flatten collection
    Enum.each collection, &store(&1)
  end

  def store(genome) do
    Agent.update(:exnn_connectome,
      &HashDict.put(&1, genome.id, genome))
  end

  # TOPOLOGY AND CONNECTIONS

  def link([], acc), do: acc

  @doc "actuators are processe as first"
  def link([{type, list} | rest], []) do
    [{previous_type, previous_list} | tail] = rest
    genomes = EXNN.Genome.collect(type, list)
    # FIXME: not sure we want to set ins at all!!!
    genomes = EXNN.Genome.set_ins(genomes, previous_list)
    link(rest, [genomes])
  end

  @doc "and sensors are last"
  def link([{first_type, first_list}], acc) do
    [outs | rest] = acc
    genomes = EXNN.Genome.collect(first_type, first_list)
    EXNN.Genome.set_outs(genomes, outs)
    link([], [genomes | acc])
  end

  def link([{type, list} | rest], acc) do
    [{previous_type, previous_list} | tail] = rest
    [outs | tail] = acc
    genomes = EXNN.Genome.collect(type, list)
    genomes = EXNN.Genome.set_ins(genomes, previous_list)
    genomes = EXNN.Genome.set_outs(genomes, outs)
    link(rest, [genomes | acc])
  end


end
