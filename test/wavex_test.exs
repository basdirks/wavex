defmodule WavexTest do
  use ExUnit.Case
  doctest Wavex

  test "greets the world" do
    assert Wavex.hello() == :world
  end
end
