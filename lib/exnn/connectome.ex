defmodule EXNN.Connectome do
  @moduledoc """
    Stores genomes forming the system,
    with their inner information.

    On boot it expands
    a pattern of the form:

    [sensor: [S_ID_1, S_ID_2, ..., S_ID_l],
     neuron: {N_1, N_2, ..., N_m},
     actuator: [A_ID_1, A_ID_2, ..., A_ID_n]

    where N_s, N_i, N_a are natural numbers,
    into a linking information between nodes with
    m hidden layers each of size N_i
  """

  alias EXNN.Utils.Random


  # TODO: decouple storage from link/patterns
  #       into Connectome.Links and Connectome.Pattern
  def start_link do
    {pattern, dimensions} = EXNN.Config.get_pattern
    Random.seed

    store = pattern
    |> EXNN.Pattern.build_layers
    |> link([], dimensions)
    |> Enum.reduce(HashDict.new, &store/2)

    Agent.start_link(fn() -> store end, name: __MODULE__)
  end

  @doc "returns the list of all genomes"
  def all do
    unkey = fn(dict)-> dict |> Enum.map(&elem &1, 1) end
    Agent.get __MODULE__, unkey
  end

  @doc "returns all neuron genomes"
  def neurons do
    Enum.filter all, &(:neuron == &1.type)
  end

  def get(id) do
    Agent.get __MODULE__, &(Dict.get &1, id)
  end

  @doc "accepts anything map or dict like"
  def update(id, dict) do
    # skim out unwanted keys!
    safe_dict = struct(EXNN.Genome, dict)

    update_fun = fn(state) ->
      genome = HashDict.get(state, id)
      # ugly but used to preserve the type
      type = genome.type
      genome = Map.merge(genome, safe_dict)
      HashDict.put state, id, %{genome | type: type}
    end

    Agent.update(__MODULE__, update_fun)
  end

  defp store(genome, hash) do
    HashDict.put(hash, genome.id, genome)
  end

  # TOPOLOGY AND CONNECTIONS

  defp link([], acc, _), do: List.flatten(acc)

  defp link([{:actuator, list} | rest], [], dimensions) do
    [{_previous_type, previous_list} | _tail] = rest
    genomes = EXNN.Genome.collect(:actuator, list)
    |> EXNN.Genome.set_ins(previous_list)
    link(rest, [genomes], dimensions)
  end

  defp link([{:sensor, first_list}], acc, dimensions) do
    [outs | _rest] = acc
    genomes = EXNN.Genome.collect(:sensor, first_list)
    |> EXNN.Genome.set_outs(outs)
    link([], [genomes | acc], dimensions)
  end

  defp link([{type, list} | rest], acc, dimensions) do
    [{_previous_type, previous_list} | _tail] = rest
    [outs | _tail] = acc
    genomes = EXNN.Genome.collect(type, list)
    |> EXNN.Genome.set_ins(previous_list, dimensions)
    |> EXNN.Genome.set_outs(outs)
    link(rest, [genomes | acc], dimensions)
  end
end
