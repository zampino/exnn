defmodule EXNN.Pattern do

  def build_layers(pattern) do
    map(pattern, [])
  end

  def map([], acc) do
    acc
  end

  def map([{type, value} | rest], acc) do
    map(rest, expand({type, value}, acc))
  end

  def expand({type, number}, acc) when is_integer(number) do
    expand({type, number}, acc, nil)
  end

  def expand({type, list}, acc) when is_list(list) do
    [{type, list} | acc]
  end

  def expand({type, tuple}, acc) when is_tuple(tuple) do
    iterator = fn(number, {acc, idx})->
      {expand({type, number}, acc, "l#{idx}"), idx + 1}
    end
    {acc, _} = List.foldl Tuple.to_list(tuple), {acc, 1}, iterator
    acc
  end

  def expand({type, number}, acc, pref) when is_integer(number) do
    names = Enum.map 1..number, &(label(type, &1, pref))
    [{type, names} | acc]
  end

  def label(type, int, prefix) do
    front = type
    if prefix do
      front = "#{front}_#{prefix}"
    end
    :"#{front}_#{int}"
  end
end
