defmodule Wavex.UtilsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Utils

  describe "taking bytes until null is encountered" do
    test "when there is no null byte present" do
      assert Utils.take_until_null(<<1, 2, 3, 4, 5, 6, 7, 8, 9>>) == <<1, 2, 3, 4, 5, 6, 7, 8, 9>>
    end

    test "when there is a null byte present" do
      assert Utils.take_until_null(<<1, 2, 0, 4, 5, 6, 7, 8, 9>>) == <<1, 2>>
    end
  end
end
