defmodule EXNN.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exnn,
      version: "0.1.0",
      elixir: "~> 1.3",
      deps: deps,
      name: "EXNN",
      description: ~s(Elixir Evolutive Neural Networks "<> <<224::utf8>> <>" la G.Sher),
      homepage_url: "https://github.com/zampino/exnn",
      consolidate_protocols: Mix.env != :test,
      docs: [
        extras: ["README.md"], main: "extra-readme",
        # source_url: "https:://github.com/zampino/exnn",
        # logo: "logo.png",
      ]
   ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger],
      # mod: {EXNN, []}
     ]
  end

  defp deps do
    [{:ex_doc, "~> 0.10", only: :dev},
    {:earmark, "~> 0.1", only: :dev}]
  end
end
