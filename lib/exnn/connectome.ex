defmodule EXNN.Connectome do

  @doc "accepts patterns of the form:

    [sensor: N_s, neuron: [l1: N_1, ..., ld: N_d], actuator: N_a]

    where N_s, N_i, N_a are natural numbers.
  "
  def start_link do
    {:ok, pid} = Agent.start_link(fn() -> HashDict.new end,
      name: __MODULE__)

    {pattern, dimensions} = EXNN.Config.get_pattern

    pattern
    |> EXNN.Pattern.build_layers
    |> link([], dimensions)
    |> store

    {:ok, pid}
  end

  def store(collection) when is_list(collection) do
    collection = List.flatten collection
    Enum.each collection, &store(&1)
  end

  def store(genome) do
    Agent.update __MODULE__,
      &HashDict.put(&1, genome.id, genome)
  end

  # TOPOLOGY AND CONNECTIONS

  def link([], acc, _), do: acc

  @doc "actuators are processe as first"
  def link([{:actuator, list} | rest], [], dimensions) do
    [{previous_type, previous_list} | tail] = rest
    genomes = EXNN.Genome.collect(:actuator, list)
    |> EXNN.Genome.set_ins(previous_list)
    link(rest, [genomes], dimensions)
  end

  @doc "and sensors are last"
  def link([{:sensor, first_list}], acc, dimensions) do
    [outs | rest] = acc
    genomes = EXNN.Genome.collect(:sensor, first_list)
    |> EXNN.Genome.set_outs(outs)
    link([], [genomes | acc], dimensions)
  end

  def link([{type, list} | rest], acc, dimensions) do
    [{previous_type, previous_list} | tail] = rest
    [outs | tail] = acc
    genomes = EXNN.Genome.collect(type, list)
    |> EXNN.Genome.set_ins(previous_list, dimensions)
    |> EXNN.Genome.set_outs(outs)
    link(rest, [genomes | acc], dimensions)
  end


end
