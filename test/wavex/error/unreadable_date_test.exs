defmodule Wavex.Error.UnreadableDateTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.UnreadableDate

  describe "converting an UnreadableDate error to string" do
    test "for an actual value of \"2000-01   \"" do
      assert to_string(%UnreadableDate{actual: "2000-01   "}) ==
               "expected date to be of the form \"yyyy-mm-dd\", got: \"2000-01   \""
    end
  end
end
