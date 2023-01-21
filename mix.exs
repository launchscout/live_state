defmodule LiveState.MixProject do
  use Mix.Project

  @description "A package to manage web application state"

  def project do
    [
      app: :live_state,
      version: "0.6.1",
      elixir: ">= 1.12.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      package: [
        licenses: ["MIT"],
        links: %{"Github" => "https://github.com/gaslight/live_state"}
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, ">= 1.5.7"},
      {:ex_doc, ">= 0.0.0"},
      {:json_diff, ">= 0.0.0"}
    ]
  end
end
