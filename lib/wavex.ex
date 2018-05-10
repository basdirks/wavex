defmodule Wavex do
  @moduledoc """
  Read LPCM WAVE data.
  """

  alias Wavex.Chunk.{Data, Format, RIFF}
  alias Wavex.Error

  defstruct [:riff, :format, :data]

  @type t :: %__MODULE__{
          riff: RIFF.t(),
          format: Format.t(),
          data: Data.t()
        }

  @doc ~S"""
  Read LPCM WAVE data.

  For more details, see `Wavex.Chunk.RIFF.read/1`, `Wavex.Chunk.Format.read/1`,
  and `Wavex.Chunk.Data.read/1`.

  ## Examples

  Reading a 16-bit stereo 88200b/s LPCM file:
      
      iex> Wavex.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x34, 0x00, 0x00, 0x00, #  52
      ...>   0x57, 0x41, 0x56, 0x45, #  W     A     V     E
      ...>   0x66, 0x6D, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00, #  4           16
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x08, 0x00, 0x00, 0x00, #  8
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:ok,
       %Wavex{
         data: %Wavex.Chunk.Data{
           data: <<0, 0, 0, 0, 0, 0, 0, 0>>,
           size: 8
         },
         format: %Wavex.Chunk.Format{
           bits_per_sample: 16,
           block_align: 4,
           byte_rate: 88_200,
           channels: 2,
           sample_rate: 22_050
         },
         riff: %Wavex.Chunk.RIFF{size: 52}
       }}

  Reading a 16-bit mono 22050/s LPCM file:

      iex> Wavex.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x30, 0x00, 0x00, 0x00, #  48
      ...>   0x57, 0x41, 0x56, 0x45, #  W     A     V     E
      ...>   0x66, 0x6D, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x01, 0x00, #  1           1
      ...>   0x11, 0x2B, 0x00, 0x00, #  11025
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x02, 0x00, 0x10, 0x00, #  2           16
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x04, 0x00, 0x00, 0x00, #  4
      ...>   0x00, 0x00, 0xFE, 0xFF  #  0     0     254   255
      ...> >>)
      {:ok,
       %Wavex{
         data: %Wavex.Chunk.Data{data: <<0, 0, 254, 255>>, size: 4},
         format: %Wavex.Chunk.Format{
           bits_per_sample: 16,
           block_align: 2,
           byte_rate: 22_050,
           channels: 1,
           sample_rate: 11_025
         },
         riff: %Wavex.Chunk.RIFF{size: 48}
       }}

  """
  @spec read(binary) :: {:ok, t} | {:error, Error.t()}
  def read(binary) when is_binary(binary) do
    with {:ok, %RIFF{} = riff, etc} <- RIFF.read(binary),
         {:ok, %Format{} = format, etc} <- Format.read(etc),
         {:ok, %Data{} = data} <- Data.read(etc) do
      {:ok, %Wavex{riff: riff, format: format, data: data}}
    end
  end
end
