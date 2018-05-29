defmodule Wavex.Chunk.DataTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Chunk.Data
  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}

  describe "reading a data chunk" do
    test "from an empty binary" do
      assert Data.read("") == {:error, %UnexpectedEOF{}}
    end

    test "of size 8" do
      binary = <<
        "data",
        <<0x0008::32-little>>,
        (<<0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>)
      >>

      assert Data.read(binary) == {:ok, %Data{size: 8, data: <<0, 0, 0, 0, 0, 0, 0, 0>>}, ""}
    end

    test "without a data id" do
      binary = <<
        "list",
        <<0x0008::32-little>>,
        (<<0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>)
      >>

      assert Data.read(binary) == {:error, %UnexpectedFourCC{expected: "data", actual: "list"}}
    end
  end
end
