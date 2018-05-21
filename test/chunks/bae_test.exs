defmodule Wavex.Chunk.BAETest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Chunk.BAE
  alias Wavex.Error.UnexpectedEOF

  describe "reading a BAE chunk" do
    test "from an empty binary" do
      assert BAE.read("") == {:error, %UnexpectedEOF{}}
    end

    test "from the wild" do
      result =
        "./priv/sine_wave.bin"
        |> File.read!()
        |> BAE.read()

      assert match?(
               {:ok,
                %BAE{
                  description: "Sine Wave File",
                  loudness_range: 0,
                  loudness_value: 0,
                  max_momentary_loudness: 0,
                  max_short_term_loudness: 0,
                  max_true_peak_level: 0,
                  origination_date: ~D[2017-06-03],
                  origination_time: ~T[13:42:10],
                  originator: "Tones.exe",
                  originator_reference: "",
                  size: 604,
                  time_reference_high: 0,
                  time_reference_low: 0,
                  umid: _,
                  version: 0
                }, ""},
               result
             )
    end
  end
end
