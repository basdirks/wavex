defmodule Wavex.CStringTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Wavex.CString

  describe "reading a null-terminated string is encountered" do
    property "CString.read(a) == a if a does not contain a null byte" do
      check all a <- StreamData.binary(),
                not String.contains?(a, <<0>>) do
        assert CString.read(a) == a
      end
    end

    property "CString.read(a <> <<0>>) == a if does not contain a null byte" do
      check all a <- StreamData.binary(),
                not String.contains?(a, <<0>>),
                b = a <> <<0>> do
        assert CString.read(b) == a
      end
    end
  end
end
