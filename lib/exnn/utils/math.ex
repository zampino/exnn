defmodule EXNN.Utils.Math do

  def tanh(x) do
    :math.tanh x
  end

  def id(x) do
    x
  end

  def labelled_scalar_product({id, weight}, {memo, acc}) do
    {val, acc} = Keyword.pop_first acc, id
    {memo + weight * val, acc}
  end

  def inv_sqrt(num) do
    1/:math.sqrt(num)
  end
end
