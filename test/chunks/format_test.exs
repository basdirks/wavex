defmodule Wavex.Chunk.FormatTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Chunk.Format

  alias Wavex.Error.{
    UnexpectedFourCC,
    UnexpectedFormatSize,
    UnsupportedFormat,
    ZeroChannels,
    BlockAlignMismatch,
    UnsupportedBitrate
  }

  describe "reading a format chunk" do
    test "of a 16-bit stereo 88.2kb/s LPCM file" do
      binary = <<
        "fmt ",
        0x00000010::32-little,
        0x0001::16-little,
        0x0002::16-little,
        0x00005622::32-little,
        0x00015888::32-little,
        0x0004::16-little,
        0x0010::16-little
      >>

      assert Format.read(binary) ==
               {:ok,
                %Format{
                  bits_per_sample: 16,
                  block_align: 4,
                  byte_rate: 88_200,
                  channels: 2,
                  sample_rate: 22_050
                }, ""}
    end

    test "without a format id" do
      binary = <<
        "list",
        0x00000010::32-little,
        0x0001::16-little,
        0x0002::16-little,
        0x00005622::32-little,
        0x00015888::32-little,
        0x0004::16-little,
        0x0010::16-little
      >>

      assert Format.read(binary) == {:error, %UnexpectedFourCC{expected: "fmt ", actual: "list"}}
    end

    test "with a format size other than 16" do
      binary = <<
        "fmt ",
        0x00000012::32-little,
        0x0001::16-little,
        0x0002::16-little,
        0x00005622::32-little,
        0x00015888::32-little,
        0x0004::16-little,
        0x0010::16-little
      >>

      assert Format.read(binary) == {:error, %UnexpectedFormatSize{actual: 18}}
    end

    test "with a format other than 1 (LPCM)" do
      binary = <<
        "fmt ",
        0x00000010::32-little,
        0x0005::16-little,
        0x0002::16-little,
        0x00005622::32-little,
        0x00015888::32-little,
        0x0004::16-little,
        0x0010::16-little
      >>

      assert Format.read(binary) == {:error, %UnsupportedFormat{actual: 0x0005}}
    end

    test "with 0 channels" do
      binary = <<
        "fmt ",
        0x00000010::32-little,
        0x0001::16-little,
        0x0000::16-little,
        0x00005622::32-little,
        0x00015888::32-little,
        0x0004::16-little,
        0x0010::16-little
      >>

      assert Format.read(binary) == {:error, %ZeroChannels{}}
    end

    test "where the byte rate is not sample_rate * block_align" do
      binary = <<
        "fmt ",
        0x00000010::32-little,
        0x0001::16-little,
        0x0002::16-little,
        0x00005622::32-little,
        0x00015888::32-little,
        0x0002::16-little,
        0x0010::16-little
      >>

      assert Format.read(binary) == {:error, %BlockAlignMismatch{expected: 4, actual: 2}}
    end

    test "where the bit rate is not 8, 16, or 24, but 32" do
      binary = <<
        "fmt ",
        0x00000010::32-little,
        0x0001::16-little,
        0x0002::16-little,
        0x00005622::32-little,
        0x00015888::32-little,
        0x0004::16-little,
        0x0020::16-little
      >>

      assert Format.read(binary) == {:error, %UnsupportedBitrate{actual: 32}}
    end
  end
end
