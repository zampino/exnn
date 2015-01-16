defmodule EXNN.Math do


  def tanh(x) do
    :math.tanh x
  end

  def id(x) do
    x
  end

  def affine_linear(inputs, weights, bias) do
    zipped = List.zip [inputs, weights]
    multiply = fn({a, b}) -> a * b end
    sum = zipped |> Enum.map(multiply) |> Enum.sum
    sum + bias
  end

end
