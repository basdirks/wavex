defmodule Wavex.Error.BlockAlignMismatchTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.BlockAlignMismatch

  describe "converting a BlockAlignMismatch error to string" do
    test "for an expected value of 1 and an actual value of 2" do
      assert to_string(%BlockAlignMismatch{expected: 1, actual: 2}) ==
               "expected block align 1, got: 2"
    end
  end
end
