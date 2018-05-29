defmodule Wavex.Error.RIFFSizeMismatchTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.RIFFSizeMismatch

  describe "converting a RIFFSizeMismatch error to string" do
    test "for an expected RIFF size of 202, and an actual RIFF size of 200" do
      assert to_string(%RIFFSizeMismatch{expected: 202, actual: 200}) ==
               "expected RIFF size 202, got: 200"
    end
  end
end
