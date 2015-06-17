defmodule EXNN.Utils.Random do
  @moduledoc false
  # NOTE: Randomness is NOT Math
  import EXNN.Utils.Logger
  import EXNN.Utils.Math, only: [pi: 0]

  def seed do
    :random.seed :erlang.now
  end

  def uniform do
    :random.uniform
  end

  def coefficient(value) do
    value * pi * (:random.uniform - 0.5)
  end

  def take(list) do
    [return] = take(list, 1)
    return
  end

  @doc "randomly chooses size distinct elements out of list"
  def take(list, size) when is_integer(size) do
    0..length(list)-1
    |> Enum.shuffle
    |> Enum.take(size)
    |> Enum.map(fn(index)-> Enum.at(list, index) end)
  end

  @doc "choses elements out of set with probability p"
  def sample(set, p) when is_list(set) do
    filtered = Enum.filter(set, &(&1 && uniform < p))
    filtered
  end

end
