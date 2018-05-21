defmodule WavexTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.{Error, Utils}
  alias Wavex.Chunk.{Data, Format, RIFF}

  alias Wavex.Error.{
    BlockAlignMismatch,
    ByteRateMismatch,
    MissingChunks,
    RIFFSizeMismatch,
    UnexpectedEOF,
    UnexpectedFormatSize,
    UnexpectedFourCC,
    UnreadableDate,
    UnreadableTime,
    UnsupportedBitrate,
    UnsupportedFormat,
    ZeroChannels
  }

  doctest BlockAlignMismatch
  doctest ByteRateMismatch
  doctest Error
  doctest MissingChunks
  doctest RIFFSizeMismatch
  doctest UnexpectedEOF
  doctest UnexpectedFormatSize
  doctest UnexpectedFourCC
  doctest UnreadableDate
  doctest UnreadableTime
  doctest UnsupportedBitrate
  doctest UnsupportedFormat
  doctest Utils
  doctest Wavex
  doctest ZeroChannels

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
      {:ok, wave} = read("M1F1-uint8-AFsp")

      assert match?(
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
               },
               wave
             )
    end

    # Mu-law encoding is not supported.
    test "M1F1-mulaw-AFsp" do
      assert read("M1F1-mulaw-AFsp") == {:error, %UnexpectedFormatSize{actual: 18}}
    end

    test "178186__snapper4298__camera-click-nikon" do
      {:ok, wave} = read("178186__snapper4298__camera-click-nikon")

      assert match?(
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
               },
               wave
             )
    end

    # The IEEE_FLOAT format is not supported.
    test "415090__gusgus26__click-04" do
      assert read("415090__gusgus26__click-04") == {:error, %UnsupportedFormat{actual: 3}}
    end

    test "213148__radiy__click" do
      {:ok, wave} = read("213148__radiy__click")

      assert match?(
               %Wavex{
                 data: %Wavex.Chunk.Data{
                   data: _,
                   size: 18_510
                 },
                 format: %Wavex.Chunk.Format{
                   bits_per_sample: 16,
                   block_align: 2,
                   byte_rate: 88_200,
                   channels: 1,
                   sample_rate: 44_100
                 },
                 riff: %Wavex.Chunk.RIFF{size: 18_546}
               },
               wave
             )
    end

    test "262301__boulderbuff64__tongue-click" do
      {:ok, wave} = read("262301__boulderbuff64__tongue-click")

      assert match?(
               %Wavex{
                 data: %Wavex.Chunk.Data{
                   data: _,
                   size: 25_600
                 },
                 format: %Wavex.Chunk.Format{
                   bits_per_sample: 16,
                   block_align: 4,
                   byte_rate: 176_400,
                   channels: 2,
                   sample_rate: 44_100
                 },
                 riff: %Wavex.Chunk.RIFF{size: 25_916}
               },
               wave
             )
    end

    test "404551__inspectorj__clap-single-9" do
      {:ok, wave} = read("404551__inspectorj__clap-single-9")

      assert match?(
               %Wavex{
                 data: %Wavex.Chunk.Data{
                   data: _,
                   size: 164_160
                 },
                 format: %Wavex.Chunk.Format{
                   bits_per_sample: 24,
                   block_align: 6,
                   byte_rate: 264_600,
                   channels: 2,
                   sample_rate: 44_100
                 },
                 riff: %Wavex.Chunk.RIFF{size: 164_304}
               },
               wave
             )
    end
  end

  describe "reading pre-defined binary values:" do
    test "16-bit stereo 88200b/s LPCM" do
      binary =
        <<
          "RIFF",
          0x0000002C::32-little,
          "WAVE",
          "fmt ",
          0x00000010::32-little,
          0x0001::16-little,
          0x0002::16-little,
          0x00005622::32-little,
          0x00015888::32-little,
          0x0004::16-little,
          0x0010::16-little,
          "data",
          0x00000008::32-little
        >> <> String.duplicate(<<0>>, 8)

      assert Wavex.read(binary) ==
               {:ok,
                %Wavex{
                  data: %Wavex.Chunk.Data{
                    data: <<0, 0, 0, 0, 0, 0, 0, 0>>,
                    size: 8
                  },
                  format: %Wavex.Chunk.Format{
                    bits_per_sample: 16,
                    block_align: 4,
                    byte_rate: 88_200,
                    channels: 2,
                    sample_rate: 22_050
                  },
                  riff: %Wavex.Chunk.RIFF{size: 44}
                }}
    end

    test "16-bit mono 22050/s LPCM" do
      binary = <<
        "RIFF",
        0x00000028::32-little,
        "WAVE",
        "fmt ",
        0x00000010::32-little,
        0x0001::16-little,
        0x0001::16-little,
        0x00002B11::32-little,
        0x00005622::32-little,
        0x0002::16-little,
        0x0010::16-little,
        "data",
        0x00000004::32-little,
        0x00,
        0x00,
        0xFE,
        0xFF
      >>

      assert Wavex.read(binary) ==
               {:ok,
                %Wavex{
                  data: %Wavex.Chunk.Data{data: <<0, 0, 254, 255>>, size: 4},
                  format: %Wavex.Chunk.Format{
                    bits_per_sample: 16,
                    block_align: 2,
                    byte_rate: 22_050,
                    channels: 1,
                    sample_rate: 11_025
                  },
                  riff: %Wavex.Chunk.RIFF{size: 40}
                }}
    end

    test "16-bit mono 22050/s LPCM, with different order of chunks" do
      binary = <<
        "RIFF",
        0x00000028::32-little,
        "WAVE",
        "data",
        0x00000004::32-little,
        0x00,
        0x00,
        0xFE,
        0xFF,
        "fmt ",
        0x00000010::32-little,
        0x0001::16-little,
        0x0001::16-little,
        0x00002B11::32-little,
        0x00005622::32-little,
        0x0002::16-little,
        0x0010::16-little
      >>

      assert Wavex.read(binary) ==
               {:ok,
                %Wavex{
                  data: %Wavex.Chunk.Data{data: <<0, 0, 254, 255>>, size: 4},
                  format: %Wavex.Chunk.Format{
                    bits_per_sample: 16,
                    block_align: 2,
                    byte_rate: 22_050,
                    channels: 1,
                    sample_rate: 11_025
                  },
                  riff: %Wavex.Chunk.RIFF{size: 40}
                }}
    end
  end

  describe "calculating the duration of a Wavex value" do
    test "of 100000 samples at 88200b/s" do
      wave = %Wavex{
        data: %Wavex.Chunk.Data{
          data:
            0
            |> List.duplicate(100_000)
            |> List.to_string(),
          size: 100_000
        },
        format: %Wavex.Chunk.Format{
          bits_per_sample: 8,
          block_align: 2,
          byte_rate: 88_200,
          channels: 2,
          sample_rate: 44_100
        },
        riff: %Wavex.Chunk.RIFF{size: 100_036}
      }

      assert Wavex.duration(wave) == 1.1337868480725624
    end

    test "for 100000 samples at 176400b/s." do
      wave = %Wavex{
        data: %Wavex.Chunk.Data{
          data:
            0
            |> List.duplicate(100_000)
            |> List.to_string(),
          size: 100_000
        },
        format: %Wavex.Chunk.Format{
          bits_per_sample: 16,
          block_align: 4,
          byte_rate: 176_400,
          channels: 2,
          sample_rate: 44_100
        },
        riff: %Wavex.Chunk.RIFF{size: 100_036}
      }

      assert Wavex.duration(wave) == 0.5668934240362812
    end
  end

  describe "mapping over data of a Wavex value" do
    def wave(bits_per_sample) do
      %Wavex{
        riff: %RIFF{
          size: 60
        },
        format: %Format{
          bits_per_sample: bits_per_sample,
          block_align: div(bits_per_sample, 8),
          byte_rate: 88_200,
          channels: 2,
          sample_rate: 44_100
        },
        data: %Data{
          size: 24,
          data: String.duplicate(<<0x00>>, 24)
        }
      }
    end

    test "with 8-bit data" do
      assert Wavex.map(wave(8), &(&1 + 0x12)).data.data == String.duplicate(<<0x12>>, 24)
    end

    test "with 16-bit data" do
      assert Wavex.map(wave(16), &(&1 - 0x1234)).data.data ==
               String.duplicate(<<-0x1234::16-signed-little>>, 12)
    end

    test "with 24-bit data" do
      assert Wavex.map(wave(24), &(&1 + 0x123456)).data.data ==
               String.duplicate(<<0x123456::24-signed-little>>, 8)
    end
  end
end
