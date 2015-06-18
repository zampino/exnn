defmodule EXNN.Application do
  @moduledoc """
    _Gentle wrapper around OTP Application + DSL importer_
  """

  defmacro __using__(opts) do
    quote do
      unquote import_dsl()
      use Application
    end
  end

  defp import_dsl do
    quote location: :keep do
      Module.register_attribute(__MODULE__, :nodes, accumulate: true)
      import EXNN.DSL
      @before_compile EXNN.DSL
    end
  end

end
