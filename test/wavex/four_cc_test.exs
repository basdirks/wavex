defmodule Wavex.FourCCTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Wavex.FourCC
  alias Wavex.Error.UnexpectedFourCC

  def four_cc_generator, do: StreamData.string(?A..?Z, length: 4)

  describe "verifying a FourCC" do
    property "FourCC.verify(a, b) always returns an error tuple if a != b" do
      check all a <- four_cc_generator(),
                b <- four_cc_generator(),
                a != b do
        assert FourCC.verify(a, b) == {:error, %UnexpectedFourCC{expected: b, actual: a}}
      end
    end

    property "FourCC.verify(a, b) always returns :ok if a == b" do
      check all a <- four_cc_generator() do
        assert FourCC.verify(a, a) == :ok
      end
    end
  end
end
