defmodule Wavex.Error.UnexpectedEOFTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.UnexpectedEOF

  describe "converting an UnexpectedEOF error to string" do
    test "for the only possible instance of UnexpectedEOF" do
      assert to_string(%UnexpectedEOF{}) == "expected more data, got an end of file"
    end
  end
end
