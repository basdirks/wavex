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

  defp read(name) do
    "priv/#{name}.wav"
    |> File.read!()
    |> Wavex.read()
  end

  describe "reading WAVE files found in the wild:" do
    # A-law encoding is not supported.
    test "M1F1-Alaw-AFsp" do
      assert read("M1F1-Alaw-AFsp") == {:error, %UnexpectedFormatSize{actual: 18}}
    end

    test "M1F1-uint8-AFsp" do
      wavex = read("M1F1-uint8-AFsp")

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
               wavex
             )
    end

    # Mu-law encoding is not supported.
    test "M1F1-mulaw-AFsp" do
      assert read("M1F1-mulaw-AFsp") == {:error, %UnexpectedFormatSize{actual: 18}}
    end

    test "178186__snapper4298__camera-click-nikon" do
      wavex = read("178186__snapper4298__camera-click-nikon")

      assert match?(
               {:ok,
                %Wavex{
                  data: %Data{
                    data: _,
                    size: 90_340
                  },
                  format: %Format{
                    bits_per_sample: 16,
                    block_align: 4,
                    byte_rate: 176_400,
                    channels: 2,
                    sample_rate: 44_100
                  },
                  riff: %RIFF{size: 90_480}
                }},
               wavex
             )
    end

    # The IEEE_FLOAT format is not supported.
    test "415090__gusgus26__click-04" do
      assert read("415090__gusgus26__click-04") == {:error, %UnsupportedFormat{actual: 3}}
    end

    test "213148__radiy__click" do
      wavex = read("213148__radiy__click")

      assert match?(
               {:ok,
                %Wavex{
                  data: %Wavex.Chunk.Data{
                    data: _,
                    size: 18510
                  },
                  format: %Wavex.Chunk.Format{
                    bits_per_sample: 16,
                    block_align: 2,
                    byte_rate: 88200,
                    channels: 1,
                    sample_rate: 44100
                  },
                  riff: %Wavex.Chunk.RIFF{size: 18546}
                }},
               wavex
             )
    end

    test "262301__boulderbuff64__tongue-click" do
      wavex = read("262301__boulderbuff64__tongue-click")

      assert match?(
               {:ok,
                %Wavex{
                  data: %Wavex.Chunk.Data{
                    data: _,
                    size: 25600
                  },
                  format: %Wavex.Chunk.Format{
                    bits_per_sample: 16,
                    block_align: 4,
                    byte_rate: 176_400,
                    channels: 2,
                    sample_rate: 44100
                  },
                  riff: %Wavex.Chunk.RIFF{size: 25916}
                }},
               wavex
             )
    end
  end
end
