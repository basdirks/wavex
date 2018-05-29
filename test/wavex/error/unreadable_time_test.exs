defmodule Wavex.Error.UnreadableTimeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.UnreadableTime

  describe "converting an UnreadableTime error to string" do
    test "for an actual value of \"12-00   \"" do
      assert to_string(%UnreadableTime{actual: "12-00   "}) ==
               "expected time to be of the form \"hh-mm-ss\", got: \"12-00   \""
    end
  end
end
