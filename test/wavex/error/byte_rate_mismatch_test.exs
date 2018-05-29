defmodule Wavex.Error.ByteRateMismatchTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.ByteRateMismatch

  describe "converting a ByteRateMismatch error to string" do
    test "for an expected value of 44100 and an actual value of 88200" do
      assert to_string(%ByteRateMismatch{expected: 44_100, actual: 88_200}) ==
               "expected byte rate 44100, got: 88200"
    end
  end
end
