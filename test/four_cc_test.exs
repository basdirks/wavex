defmodule Wavex.FourCCTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.FourCC
  alias Wavex.Error.UnexpectedFourCC

  describe "verifying a FourCC" do
    test "with a non-binary value" do
      assert_raise FunctionClauseError, fn ->
        FourCC.verify(1234, "fmt ")
      end
    end

    test "with a binary size other than 32" do
      assert_raise FunctionClauseError, fn ->
        FourCC.verify("fmt", "fmt ")
      end
    end

    test "which was expected" do
      assert FourCC.verify("RIFF", "RIFF") == :ok
    end

    test "which was unexpected" do
      assert FourCC.verify("RIFX", "RIFF") ==
               {:error, %UnexpectedFourCC{expected: "RIFF", actual: "RIFX"}}
    end
  end
end
