defmodule EXNN.Utils.Random do
  @moduledoc false
  import EXNN.Utils.Math, only: [pi: 0]

  def seed do
    :rand.seed :exs1024, :os.timestamp
  end

  def uniform do
    :rand.uniform
  end

  def coefficient(value) do
    value * pi * (:rand.uniform - 0.5)
  end

  def take(list) do
    [return] = take(list, 1)
    return
  end

  @doc "randomly chooses size distinct elements out of list"
  def take(list, size) when is_integer(size) do
    # seed
    # 0..length(list)-1
    # |> Enum.shuffle
    # |> Enum.take(size)
    # |> Enum.map(fn(index)-> Enum.at(list, index) end)
    Enum.take_random list, size
  end

  @doc "choses elements out of set with probability p"
  def sample(set, p) when is_list(set) do
    filtered = Enum.filter(set, &(&1 && uniform < p))
    filtered
  end

end
