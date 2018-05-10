defmodule WavexTest do
  @moduledoc false

  use ExUnit.Case

  alias Wavex.{Error, Utils}
  alias Wavex.Chunk.{Data, Format, RIFF}

  alias Wavex.Error.{
    BlockAlignMismatch,
    ByteRateMismatch,
    UnexpectedEOF,
    UnexpectedFormatSize,
    UnexpectedFourCC,
    UnsupportedBitsPerSample,
    UnsupportedFormat,
    ZeroChannels
  }

  doctest Wavex
  doctest Data
  doctest Error
  doctest BlockAlignMismatch
  doctest ByteRateMismatch
  doctest UnexpectedEOF
  doctest UnexpectedFormatSize
  doctest UnexpectedFourCC
  doctest UnsupportedBitsPerSample
  doctest UnsupportedFormat
  doctest ZeroChannels
  doctest Format
  doctest RIFF
  doctest Utils

  defp read(name), do: File.read!("priv/#{name}.wav")

  describe "reading WAVE files" do
    test "stereo A-law data" do
      wave =
        "M1F1-Alaw-AFsp"
        |> read()
        |> Wavex.read()

      assert wave == {:error, %UnexpectedFormatSize{actual: 18}}
    end

    test "stereo unsigned 8-bit data" do
      with etc <- read("M1F1-uint8-AFsp"),
           {:ok, _, etc} <- RIFF.read(etc),
           {:ok, format, _} <- Format.read(etc) do
        assert format == %Format{
                 bits_per_sample: 8,
                 block_align: 2,
                 byte_rate: 16_000,
                 channels: 2,
                 sample_rate: 8000
               }
      end

      wave =
        "M1F1-uint8-AFsp"
        |> read()
        |> Wavex.read()

      assert match?(
               {:ok,
                %Wavex{
                  data: %Data{
                    data: _,
                    size: 46_986
                  },
                  format: %Format{
                    bits_per_sample: 8,
                    block_align: 2,
                    byte_rate: 16_000,
                    channels: 2,
                    sample_rate: 8000
                  },
                  riff: %RIFF{size: 47_188}
                }},
               wave
             )
    end

    test "stereo µ-law data" do
      wave =
        "M1F1-mulaw-AFsp"
        |> read()
        |> Wavex.read()

      assert wave == {:error, %UnexpectedFormatSize{actual: 18}}
    end
  end
end
