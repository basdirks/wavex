defmodule Wavex do
  @moduledoc """
  Reading PCM WAVE files.
  """

  alias Wavex.{DataChunk, FormatChunk, RIFFHeader}

  alias Wavex.Error.{
    BlockAlignMismatch,
    ByteRateMismatch,
    UnexpectedEOF,
    UnexpectedFormatSize,
    UnexpectedID,
    UnsupportedBitsPerSample,
    UnsupportedFormat,
    ZeroChannels
  }

  defstruct [:riff_header, :format_chunk, :data_chunk]

  @type t :: %__MODULE__{
          riff_header: RIFFHeader.t(),
          format_chunk: FormatChunk.t(),
          data_chunk: DataChunk.t()
        }

  @doc ~S"""
  Read a PCM WAVE file.

  ## Examples
      
  [sapp.org, 2018-04-30, Microsoft WAVE soundfile format](http://soundfile.sapp.org/doc/WaveFormat/)

      iex Wavex.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x24, 0x08, 0x00, 0x00, #  38
      ...>   0x57, 0x41, 0x56, 0x45, #  W     A     V     E
      ...>   0x66, 0x6D, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00, #  4           16
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x02, 0x00, 0x00, 0x00, #  2
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:ok,
      %Wavex{
        data_chunk: %Wavex.DataChunk{
          data: <<0, 0, 0, 0, 0, 0, 0, 0>>,
          size: 2
        },
        format_chunk: %Wavex.FormatChunk{
          bits_per_sample: 16,
          block_align: 4,
          byte_rate: 88_200,
          channels: 2,
          sample_rate: 22_050
        },
        riff_header: %Wavex.RIFFHeader{size: 2084}
      }}

      iex> Wavex.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x24, 0x08, 0x00, 0x00, #  38
      ...>   0x57, 0x41, 0x56, 0x45, #  W     A     V     E
      ...>   0x66, 0x6D, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x01, 0x00, #  1           1
      ...>   0x11, 0x2B, 0x00, 0x00, #  11025
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x02, 0x00, 0x10, 0x00, #  2           16
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x02, 0x00, 0x00, 0x00, #  2
      ...>   0x00, 0x00, 0xFE, 0xFF  #  0     0     254   255
      ...> >>)
      {:ok,
        %Wavex{
          data_chunk: %Wavex.DataChunk{data: <<0, 0, 254, 255>>, size: 2},
          format_chunk: %Wavex.FormatChunk{
            bits_per_sample: 16,
            block_align: 2,
            byte_rate: 22050,
            channels: 1,
            sample_rate: 11025
          },
          riff_header: %Wavex.RIFFHeader{size: 2084}
        }}

  """
  @spec read(binary) ::
          {:ok, t}
          | {:error,
             BlockAlignMismatch.t()
             | ByteRateMismatch.t()
             | UnexpectedEOF.t()
             | UnexpectedFormatSize.t()
             | UnexpectedID.t()
             | UnsupportedBitsPerSample.t()
             | UnsupportedFormat.t()
             | ZeroChannels.t()}
  def read(binary) when is_binary(binary) do
    with {:ok, %RIFFHeader{} = riff_header, etc} <- RIFFHeader.read(binary),
         {:ok, %FormatChunk{block_align: block_align} = format_chunk, etc} <-
           FormatChunk.read(etc),
         {:ok, %DataChunk{} = data_chunk} <- DataChunk.read(etc, block_align) do
      {:ok, %Wavex{riff_header: riff_header, format_chunk: format_chunk, data_chunk: data_chunk}}
    else
      {:error, _} = error -> error
    end
  end
end
