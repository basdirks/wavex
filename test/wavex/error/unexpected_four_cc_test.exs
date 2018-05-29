defmodule Wavex.Error.UnexpectedFourCCTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.UnexpectedFourCC

  describe "converting an UnexpectedFourCC error to string" do
    test "for an expected value of \"WAVE\", and an actual value of \"DIVX\"" do
      assert to_string(%UnexpectedFourCC{expected: "WAVE", actual: "DIVX"}) ==
               "expected FourCC \"WAVE\", got: \"DIVX\""
    end
  end
end
