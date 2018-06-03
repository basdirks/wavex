defmodule Wavex.CStringTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Wavex.CString

  def unterminated do
    ExUnitProperties.gen all binary <- StreamData.binary(),
                             not String.contains?(binary, <<0>>) do
      binary
    end
  end

  property "CString.read(a) == a if a does not contain a null byte" do
    check all binary <- unterminated() do
      assert CString.read(binary) == binary
    end
  end

  property "CString.read(binary <> <<0>>) == binary if binary does not contain a null byte" do
    check all binary <- unterminated() do
      assert CString.read(binary <> <<0>>) == binary
    end
  end
end
