defmodule EXNN.Utils.Random do
  @moduledoc false
  # NOTE: Randomness is NOT Math
  import EXNN.Utils.Logger

  def seed do
    :random.seed :erlang.now
  end

  def uniform do
    :random.uniform
  end

  def coefficient(value) do
    :math.pi * value * (:random.uniform - 1)
  end

  # def sample(set) do
  #   [return] = sample(set, 1)
  #   return
  # end

  # @doc "randomly chooses size distinct elements out of set"
  # def sample(set, size) when is_integer(size) do
  #   seed
  #   0..size-1
  #   |> Enum.shuffle
  #   |> Enum.map(fn(index)-> Enum.to_list(set) |> Enum.at(index) end)
  # end

  @doc "choses elements out of set with probability p"
  def sample(set, p) when is_list(set) do
    seed
    filtered = Enum.filter(set, &(&1 && uniform < p))
    # log "taken:", Enum.count filtered
    # log "of:", Enum.count set
    # log "with:", p
    filtered
  end

end
