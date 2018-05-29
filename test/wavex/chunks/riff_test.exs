defmodule Wavex.Chunk.RIFFTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Chunk.RIFF
  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}

  describe "reading a RIFF chunk" do
    test "from an empty binary" do
      assert RIFF.read("") == {:error, %UnexpectedEOF{}}
    end

    test "from the smallest correct binary" do
      binary = <<
        "RIFF",
        <<0x00, 0x00, 0x00, 0x00>>,
        "WAVE"
      >>

      assert RIFF.read(binary) == {:ok, %RIFF{size: 0}, ""}
    end

    test "without a RIFF id" do
      binary = <<
        "RIFX",
        <<0x00, 0x00, 0x00, 0x00>>,
        "WAVE"
      >>

      assert RIFF.read(binary) == {:error, %UnexpectedFourCC{expected: "RIFF", actual: "RIFX"}}
    end

    test "without a WAVE id" do
      binary = <<
        "RIFF",
        <<0x00, 0x00, 0x00, 0x00>>,
        "DIVX"
      >>

      assert RIFF.read(binary) == {:error, %UnexpectedFourCC{expected: "WAVE", actual: "DIVX"}}
    end

    test "of less than 12 bytes" do
      binary = <<
        "RIFF",
        <<0x00, 0x00, 0x00, 0x00>>,
        "WAV"
      >>

      assert RIFF.read(binary) == {:error, %UnexpectedEOF{}}
    end
  end
end
