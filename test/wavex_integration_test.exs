defmodule WavexIntegrationTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Wavex.Chunk.{
    Data,
    Format,
    RIFF
  }

  defp read(name) do
    "priv/#{name}.wav"
    |> File.read!()
    |> Wavex.read()
  end

  describe "reading WAVE files found in the wild:" do
    # A-law encoding is not supported.
    test "M1F1-Alaw-AFsp" do
      assert read("M1F1-Alaw-AFsp") == {:error, {:unexpected_format_size, 18}}
    end

    test "M1F1-uint8-AFsp" do
      {:ok, wave} = read("M1F1-uint8-AFsp")

      assert match?(
               %Wavex{
                 data: %Data{
                   data: _,
                   size: 46_986
                 },
                 format: %Format{
                   bits_per_sample: 8,
                   block_align: 2,
                   byte_rate: 16_000,
                   channels: 2,
                   sample_rate: 8000
                 },
                 riff: %RIFF{size: 47_188}
               },
               wave
             )
    end

    # Mu-law encoding is not supported.
    test "M1F1-mulaw-AFsp" do
      assert read("M1F1-mulaw-AFsp") == {:error, {:unexpected_format_size, 18}}
    end

    test "178186__snapper4298__camera-click-nikon" do
      {:ok, wave} = read("178186__snapper4298__camera-click-nikon")

      assert match?(
               %Wavex{
                 data: %Data{
                   data: _,
                   size: 90_340
                 },
                 format: %Format{
                   bits_per_sample: 16,
                   block_align: 4,
                   byte_rate: 176_400,
                   channels: 2,
                   sample_rate: 44_100
                 },
                 riff: %RIFF{size: 90_480}
               },
               wave
             )
    end

    # The IEEE_FLOAT format is not supported.
    test "415090__gusgus26__click-04" do
      assert read("415090__gusgus26__click-04") == {:error, {:unsupported_format, 3}}
    end

    test "213148__radiy__click" do
      {:ok, wave} = read("213148__radiy__click")

      assert match?(
               %Wavex{
                 data: %Data{
                   data: _,
                   size: 18_510
                 },
                 format: %Format{
                   bits_per_sample: 16,
                   block_align: 2,
                   byte_rate: 88_200,
                   channels: 1,
                   sample_rate: 44_100
                 },
                 riff: %RIFF{size: 18_546}
               },
               wave
             )
    end

    test "262301__boulderbuff64__tongue-click" do
      {:ok, wave} = read("262301__boulderbuff64__tongue-click")

      assert match?(
               %Wavex{
                 data: %Data{
                   data: _,
                   size: 25_600
                 },
                 format: %Format{
                   bits_per_sample: 16,
                   block_align: 4,
                   byte_rate: 176_400,
                   channels: 2,
                   sample_rate: 44_100
                 },
                 riff: %RIFF{size: 25_916}
               },
               wave
             )
    end

    test "404551__inspectorj__clap-single-9" do
      {:ok, wave} = read("404551__inspectorj__clap-single-9")

      assert match?(
               %Wavex{
                 data: %Data{
                   data: _,
                   size: 164_160
                 },
                 format: %Format{
                   bits_per_sample: 24,
                   block_align: 6,
                   byte_rate: 264_600,
                   channels: 2,
                   sample_rate: 44_100
                 },
                 riff: %RIFF{size: 164_304}
               },
               wave
             )
    end

    test "Alesis-Sanctuary-QCard-Crickets" do
      {:ok, wave} = read("Alesis-Sanctuary-QCard-Crickets")

      assert match?(
               %Wavex{
                 bae: nil,
                 data: %Data{data: <<187, 255, 173, 255>>, size: 4},
                 format: %Format{
                   bits_per_sample: 16,
                   block_align: 4,
                   byte_rate: 176_400,
                   channels: 2,
                   sample_rate: 44_100
                 },
                 riff: %RIFF{size: 158}
               },
               wave
             )
    end
  end
end
