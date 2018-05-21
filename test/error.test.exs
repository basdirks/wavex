defmodule Wavex.ErrorTest do
  @moduledoc false

  use ExUnit.Case, async: true

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

  describe "converting errors to string" do
    test "for an unsupported format" do
      assert to_string(%Wavex.Error.UnsupportedFormat{actual: 0x0000}) ==
               "expected format 1 (LPCM), got: 0 (UNKNOWN)"

      assert to_string(%Wavex.Error.UnsupportedFormat{actual: 0x0050}) ==
               "expected format 1 (LPCM), got: 80 (MPEG)"
    end

    test "an unexpected format size" do
      assert to_string(%Wavex.Error.UnexpectedFormatSize{actual: 18}) ==
               "expected format size 16, got: 18"
    end

    test "an unsupported bitrate" do
      assert to_string(%Wavex.Error.UnsupportedBitrate{actual: 32}) ==
               "expected bits per sample to be 8, 16, or 24, got: 32"
    end

    test "zero channels" do
      assert to_string(%Wavex.Error.ZeroChannels{}) == "expected a positive number of channels"
    end

    test "an unexpected end-of-file" do
      assert to_string(%Wavex.Error.UnexpectedEOF{}) == "expected more data, got an end of file"
    end

    test "a block align mismatch" do
      assert to_string(%Wavex.Error.BlockAlignMismatch{expected: 1, actual: 2}) ==
               "expected block align 1, got: 2"
    end

    test "a byte rate mismatch" do
      assert to_string(%Wavex.Error.ByteRateMismatch{expected: 44_100, actual: 88_200}) ==
               "expected byte rate 44100, got: 88200"
    end

    test "an unexpected FourCC" do
      assert to_string(%Wavex.Error.UnexpectedFourCC{expected: "WAVE", actual: "DIVX"}) ==
               "expected FourCC \"WAVE\", got: \"DIVX\""
    end

    test "an unreadable date" do
      assert to_string(%Wavex.Error.UnreadableDate{actual: "2000-01   "}) ==
               "expected date to be of the form \"yyyy-mm-dd\", got: \"2000-01   \""
    end

    test "an unreadable time" do
      assert to_string(%Wavex.Error.UnreadableTime{actual: "12-00   "}) ==
               "expected time to be of the form \"hh-mm-ss\", got: \"12-00   \""
    end

    test "a RIFF size mismatch" do
      assert to_string(%Wavex.Error.RIFFSizeMismatch{expected: 202, actual: 200}) ==
               "expected RIFF size 202, got: 200"
    end

    test "missing chunks" do
      assert to_string(%Wavex.Error.MissingChunks{missing: [Wavex.Chunk.Data]}) ==
               "missing chunks: \"[Wavex.Chunk.Data]\""
    end
  end
end
