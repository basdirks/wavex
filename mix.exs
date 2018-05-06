defmodule Wavex.MixProject do
  use Mix.Project

  def project do
    [
      app: :wavex,
      version: "0.2.2",
      elixir: "~> 1.6",
      description: "Read WAV PCM files",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/basdirks/wavex"},
      maintainers: ["Bas Dirks"],
      name: "wavex"
    ]
  end
end
