defmodule Wavex.MixProject do
  use Mix.Project

  def project do
    [
      app: :wavex,
      version: "0.15.0",
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
      extras: [{"README.md", title: "Readme"}],
      groups_for_modules: [
        Chunks: [
          Wavex.Chunk.BAE,
          Wavex.Chunk.Data,
          Wavex.Chunk.Format,
          Wavex.Chunk.RIFF
        ],
        Errors: [
          Wavex.Error,
          Wavex.Error.BlockAlignMismatch,
          Wavex.Error.ByteRateMismatch,
          Wavex.Error.MissingChunks,
          Wavex.Error.RIFFSizeMismatch,
          Wavex.Error.UnexpectedEOF,
          Wavex.Error.UnexpectedFormatSize,
          Wavex.Error.UnexpectedFourCC,
          Wavex.Error.UnreadableDate,
          Wavex.Error.UnreadableTime,
          Wavex.Error.UnsupportedBitrate,
          Wavex.Error.UnsupportedFormat,
          Wavex.Error.ZeroChannels
        ]
      ]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.13.1", only: :dev},
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
