defmodule WavexTest do
  use ExUnit.Case

  alias Wavex.{DataChunk, Error, FormatChunk, RIFFHeader, Utils}

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
  doctest DataChunk
  doctest Error
  doctest BlockAlignMismatch
  doctest ByteRateMismatch
  doctest UnexpectedEOF
  doctest UnexpectedFormatSize
  doctest UnexpectedFourCC
  doctest UnsupportedBitsPerSample
  doctest UnsupportedFormat
  doctest ZeroChannels
  doctest FormatChunk
  doctest RIFFHeader
  doctest Utils

  defp read(name) do
    File.read!("priv/#{name}.wav")
  end

  describe "reading WAVE files" do
    test "stereo A-law data" do
      wave =
        "M1F1-Alaw-AFsp"
        |> read()
        |> Wavex.read()

      assert wave == {:error, %UnexpectedFormatSize{size: 18}}
    end

    test "stereo unsigned 8-bit data" do
      with etc <- read("M1F1-uint8-AFsp"),
           {:ok, _, etc} <- RIFFHeader.read(etc),
           {:ok, format_chunk, _} <- FormatChunk.read(etc) do
        assert format_chunk == %FormatChunk{
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
                  data_chunk: %Wavex.DataChunk{
                    data: _,
                    size: 46_986
                  },
                  format_chunk: %Wavex.FormatChunk{
                    bits_per_sample: 8,
                    block_align: 2,
                    byte_rate: 16_000,
                    channels: 2,
                    sample_rate: 8000
                  },
                  riff_header: %Wavex.RIFFHeader{size: 47_188}
                }},
               wave
             )
    end
  end
end
