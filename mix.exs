defmodule Wavex.MixProject do
  use Mix.Project

  def project do
    [
      app: :wavex,
      version: "0.9.0",
      elixir: "~> 1.6",
      docs: docs(),
      description: "Read WAVE LPCM data",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  def application do
    []
  end

  defp docs do
    [
      extras: [{"README.md", title: "Readme"}]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8.2", only: :test},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/basdirks/wavex"},
      maintainers: ["Bas Dirks"],
      name: "wavex"
    ]
  end
end
