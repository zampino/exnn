defmodule EXNN.DSLTest do
  use ExUnit.Case

  defmodule BaseStruct do
    defstruct a: 1, b: "two"
  end

  defmodule TestStruct do
    import EXNN.DSL

    extend_struct BaseStruct, some: "extra", key: "with overrides", b: "three"
  end

  test "it can merge structures" do
    ts = %TestStruct{}
    map = Map.from_struct ts
    assert map == %{a: 1, b: "three", key: "with overrides", some: "extra"}
  end


end
