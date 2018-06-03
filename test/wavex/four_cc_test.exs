defmodule Wavex.FourCCTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Wavex.FourCC

  def four_cc, do: StreamData.string(?A..?Z, length: 4)

  describe "FourCC.verify(a, b)" do
    property "always returns an error tuple if a != b" do
      check all a <- four_cc(),
                b <- four_cc(),
                a != b do
        assert FourCC.verify(a, b) == {:error, {:unexpected_four_cc, %{expected: b, actual: a}}}
      end
    end

    property "always returns :ok if a == b" do
      check all a <- four_cc() do
        assert FourCC.verify(a, a) == :ok
      end
    end
  end
end
