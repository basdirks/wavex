defmodule Wavex.Error.UnexpectedFormatSizeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.UnexpectedFormatSize

  describe "converting an UnexpectedFormatSize error to string" do
    test "for an actual value of 18" do
      assert to_string(%UnexpectedFormatSize{actual: 18}) == "expected format size 16, got: 18"
    end
  end
end
