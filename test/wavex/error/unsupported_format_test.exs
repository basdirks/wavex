defmodule Wavex.Error.UnsupportedFormatTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.UnsupportedFormat

  describe "converting an UnsupportedFormat error to string" do
    test "for an actual value of 0 (UNKNOWN)" do
      assert to_string(%UnsupportedFormat{actual: 0}) ==
               "expected format 1 (LPCM), got: 0 (UNKNOWN)"
    end

    test "for an actual value of 80 (MPEG)" do
      assert to_string(%UnsupportedFormat{actual: 80}) ==
               "expected format 1 (LPCM), got: 80 (MPEG)"
    end
  end
end
