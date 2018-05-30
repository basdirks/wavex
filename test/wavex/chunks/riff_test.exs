defmodule Wavex.Chunk.RIFFTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Wavex.Chunk.RIFF
  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}

  @max_32bit 2
             |> :math.pow(32)
             |> round()

  describe "reading a RIFF chunk" do
    property "from a binary starting with a valid RIFF chunk" do
      check all size <- StreamData.integer(0..@max_32bit),
                etc <- StreamData.binary() do
        binary = <<
          "RIFF",
          size::32-little,
          "WAVE",
          etc::binary
        >>

        assert RIFF.read(binary) == {:ok, %RIFF{size: size}, etc}
      end
    end

    property "without a RIFF id" do
      check all size <- StreamData.integer(0..@max_32bit),
                id <- StreamData.binary(length: 4),
                id != "RIFF" do
        binary =
          id <>
            <<
              size::32-little,
              "WAVE"
            >>

        assert RIFF.read(binary) == {:error, %UnexpectedFourCC{expected: "RIFF", actual: id}}
      end
    end

    property "without a WAVE id" do
      check all size <- StreamData.integer(0..@max_32bit),
                id <- StreamData.binary(length: 4),
                id != "WAVE" do
        binary =
          <<
            "RIFF",
            size::32-little
          >> <> id

        assert RIFF.read(binary) == {:error, %UnexpectedFourCC{expected: "WAVE", actual: id}}
      end
    end

    property "of less than 12 bytes" do
      check all size <- StreamData.integer(0..@max_32bit),
                length <- StreamData.integer(0..11) do
        binary = <<
          "RIFF",
          size::32-little,
          "WAVE"
        >>

        part = :binary.part(binary, 0, length)

        assert RIFF.read(part) == {:error, %UnexpectedEOF{}}
      end
    end
  end
end
