defmodule EXNN.Utils.Math do

  def pi, do: :math.pi

  def id(x), do: x

  def sign(0), do: 0
  def sign(0.0), do: 0
  def sign(x) do
    :erlang.trunc(abs(x)/x)
  end

  def tanh(x), do: :math.tanh(x)

  def sqrt(x), do: :math.sqrt(x)

  def inv_sqrt(x), do: 1/:math.sqrt(x)

  def sin(x), do: :math.sin(x)

  def sigmoid(_x, _k), do: nil # TODO

  def labelled_scalar_product({id, weight}, {memo, acc}) do
    {val, acc} = Keyword.pop_first acc, id
    {memo + weight * val, acc}
  end
end
