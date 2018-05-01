defmodule Wavex do
  @moduledoc """
  Reading PCM WAVE files.
  """

  alias Wavex.{DataChunk, FormatChunk, RIFFHeader}

  defstruct [:riff_header, :format_chunk, :data_chunk]

  @type t :: %__MODULE__{
          riff_header: RIFFHeader.t(),
          format_chunk: FormatChunk.t(),
          data_chunk: DataChunk.t()
        }

  @doc ~S"""
  Read a PCM WAVE file.

  ## Examples
      
      iex> Wavex.read(<<0x0052, 0x0049, 0x0046, 0x0046, #       R      I      F      F
      ...>              0x0024, 0x0008, 0x0000, 0x0000, #      38
      ...>              0x0057, 0x0041, 0x0056, 0x0045, #       W      A      V      E
      ...>              0x0066, 0x006d, 0x0074, 0x0020, #       f      m      t     \s
      ...>              0x0010, 0x0000, 0x0000, 0x0000, #       1
      ...>              0x0001, 0x0000, 0x0002, 0x0000, #       1             2
      ...>              0x0022, 0x0056, 0x0000, 0x0000, #   22050
      ...>              0x0088, 0x0058, 0x0001, 0x0000, #   88200
      ...>              0x0004, 0x0000, 0x0010, 0x0000, #       4            16
      ...>              0x0064, 0x0061, 0x0074, 0x0061, #       d      a      t      a
      ...>              0x0002, 0x0000, 0x0000, 0x0000, #       2
      ...>              0x0000, 0x0000, 0x0000, 0x0000,
      ...>              0x0000, 0x0000, 0x0000, 0x0000>>)
      {:ok,
      %Wavex{
        data_chunk: %Wavex.DataChunk{
          data: <<0, 0, 0, 0, 0, 0, 0, 0>>,
          size: 2
        },
        format_chunk: %Wavex.FormatChunk{
          bits_per_sample: 16,
          block_align: 4,
          byte_rate: 88200,
          channels: 2,
          sample_rate: 22050
        },
        riff_header: %Wavex.RIFFHeader{size: 2084}
      }}

  """
  @spec read(binary) :: {:ok, t} | {:error, binary}
  def read(binary) when is_binary(binary) do
    with {:ok, %RIFFHeader{} = riff_header, etc} <- RIFFHeader.read(binary),
         {:ok, %FormatChunk{block_align: block_align} = format_chunk, etc} <-
           FormatChunk.read(etc),
         {:ok, %DataChunk{} = data_chunk} <- DataChunk.read(etc, block_align) do
      {:ok, %Wavex{riff_header: riff_header, format_chunk: format_chunk, data_chunk: data_chunk}}
    else
      error -> error
    end
  end
end
