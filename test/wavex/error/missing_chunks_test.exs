defmodule Wavex.Error.MissingChunksTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.MissingChunks

  describe "converting a MissingChunk error to string" do
    test "with a missing Data chunk" do
      assert to_string(%MissingChunks{missing: [Wavex.Chunk.Data]}) ==
               "missing chunks: \"[Wavex.Chunk.Data]\""
    end
  end
end
