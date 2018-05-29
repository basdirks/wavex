defmodule Wavex.Error.ZeroChannelsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Error.ZeroChannels

  describe "converting a ZeroChannels error to string" do
    test "for the only possible instance of ZeroChannels" do
      assert to_string(%ZeroChannels{}) == "expected a positive number of channels"
    end
  end
end
