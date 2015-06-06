defmodule EXNN.Config do

  def start_link(mod) do
    store = %{
      remote_nodes: mod.nodes,
      pattern: mod.initial_pattern,
      fitness: mod.fitness || {nil, nil} #,
      # mutations: mod.mutations
    }
    Agent.start_link(fn -> store end, name: __MODULE__)
  end

  def get_remote_nodes do
    Agent.get __MODULE__, &Map.get(&1, :remote_nodes)
  end

  def get_pattern do
    config = Agent.get __MODULE__, &(&1)
    {Map.get(config, :pattern), sensor_dimensions(config)}
  end

  def get_fitness do
    Agent.get __MODULE__, &Map.get(&1, :fitness)
  end

  def sensor_dimensions(config) do
    filter = fn({type, id, mod, opts})->
      type == :sensor
    end
    mapper = fn({type, id, mod, opts})->
      {id, opts[:dim]}
    end
    Map.get(config, :remote_nodes) |> Enum.filter_map(filter, mapper)
  end

  def sensors do
    filter = fn({type, id, mod, opts})->
      type == :sensor
    end
    mapper = fn({type, id, mod, opts})-> id end
    get_remote_nodes |> Enum.filter_map(filter, mapper)
  end

  def config_for(identifier) do
    search_by_id = fn({type, id, mod, opts})->
      (identifier == id) and %{type: type, id: id, mod: mod, opts: opts}
    end
    get_remote_nodes |> Enum.find_value(search_by_id)
  end
end
