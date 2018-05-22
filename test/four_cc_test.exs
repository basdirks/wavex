defmodule Wavex.FourCCTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.FourCC
  alias Wavex.Error.UnexpectedFourCC

  describe "verifying a FourCC" do
    test "which was expected" do
      assert FourCC.verify("RIFF", "RIFF") == :ok
    end

    test "which was unexpected" do
      assert FourCC.verify("RIFX", "RIFF") ==
               {:error, %UnexpectedFourCC{expected: "RIFF", actual: "RIFX"}}
    end
  end
end
