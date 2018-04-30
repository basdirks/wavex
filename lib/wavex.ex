defmodule Wavex do
  @moduledoc """
  Read PCM WAVE files.
  """

  alias Wavex.{DataChunk, FormatChunk, RIFFHeader}

  defstruct [:riff_header, :format_chunk, :data_chunk]

  @type t :: %__MODULE__{
          riff_header: RIFFHeader.t(),
          format_chunk: FormatChunk.t(),
          data_chunk: DataChunk.t()
        }

  @spec read(binary) :: {:ok, t} | {:error, binary}
  def read(binary) when is_binary(binary) do
    with {:ok, %RIFFHeader{} = riff_header, etc} <- RIFFHeader.read(binary),
         {:ok, %FormatChunk{} = format_chunk, etc} <- FormatChunk.read(etc),
         {:ok, %DataChunk{}} = data_chunk <- DataChunk.read(etc) do
      {:ok, %Wavex{riff_header: riff_header, format_chunk: format_chunk, data_chunk: data_chunk}}
    else
      error -> error
    end
  end
end
