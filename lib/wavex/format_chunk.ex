defmodule Wavex.FormatChunk do
  @moduledoc """
  Read a format chunk.
  """

  alias Wavex.Utils

  defstruct [:channels, :sample_rate, :byte_rate, :block_align, :bits_per_sample]

  @type t :: %__MODULE__{
          channels: pos_integer,
          sample_rate: pos_integer,
          byte_rate: pos_integer,
          block_align: pos_integer,
          bits_per_sample: pos_integer
        }

  @spec read_size(binary) :: {:ok | :error, binary}
  defp read_size(<<size::32-little, etc::binary>>) do
    case size do
      16 -> {:ok, etc}
      _ -> {:error, "expected format size 16, got: #{size}"}
    end
  end

  @spec format_name(non_neg_integer) :: binary
  defp format_name(format) do
    case format do
      0x0002 -> "ADPCM"
      0x0003 -> "IEEE_FLOAT"
      0xFFFE -> "EXTENSIBLE"
      _ -> "UNKNOWN"
    end
  end

  @spec read_format(binary) :: {:ok | :error, binary}
  defp read_format(<<format::16-little, etc::binary>>) do
    case format do
      1 -> {:ok, etc}
      _ -> {:error, "expected format 1 (PCM), got: #{format} (#{format_name(format)})"}
    end
  end

  @spec verify_bits_per_sample(non_neg_integer) :: :ok | {:error, binary}
  defp verify_bits_per_sample(bits_per_sample) when bits_per_sample in [8, 16, 24], do: :ok

  defp verify_bits_per_sample(bits_per_sample) do
    {:error, "expected bits per sample to be 8, 16, or 24, got: #{bits_per_sample}"}
  end

  @spec verify_channels(non_neg_integer) :: :ok | {:error, binary}
  defp verify_channels(0), do: {:error, "expected channels > 0"}
  defp verify_channels(_), do: :ok

  @spec validate(t) :: :ok | {:error, binary}
  defp validate(%__MODULE__{
         bits_per_sample: bits_per_sample,
         block_align: block_align,
         byte_rate: byte_rate,
         channels: channels,
         sample_rate: sample_rate
       }) do
    with :ok <- verify_channels(channels),
         :ok <- verify_bits_per_sample(bits_per_sample),
         :ok <- Utils.verify("block align", channels * div(bits_per_sample, 8), block_align),
         :ok <- Utils.verify("byte rate", sample_rate * block_align, byte_rate) do
      :ok
    else
      error -> error
    end
  end

  @doc ~S"""
  Read a format chunk.

  ## Examples

  From [sapp.org, 2018-04-30, Microsoft WAVE soundfile format](http://soundfile.sapp.org/doc/WaveFormat/):

      iex> Wavex.FormatChunk.read(<<0x0066, 0x006d, 0x0074, 0x0020,
      ...>                          0x0010, 0x0000, 0x0000, 0x0000,
      ...>                          0x0001, 0x0000, 0x0002, 0x0000,
      ...>                          0x0022, 0x0056, 0x0000, 0x0000,
      ...>                          0x0088, 0x0058, 0x0001, 0x0000,
      ...>                          0x0004, 0x0000, 0x0010, 0x0000>>)
      {:ok,
      %Wavex.FormatChunk{
        bits_per_sample: 16,
        block_align: 4,
        byte_rate: 88200,
        channels: 2,
        sample_rate: 22050
      }, ""}

  """

  @spec read(binary) :: {:ok, t, binary} | {:error, binary}
  def read(binary) when is_binary(binary) do
    with {:ok, etc} <- Utils.read_id(binary, "fmt "),
         {:ok, etc} <- read_size(etc),
         {:ok, etc} <- read_format(etc),
         <<channels::16-little, etc::binary>> <- etc,
         <<sample_rate::32-little, etc::binary>> <- etc,
         <<byte_rate::32-little, etc::binary>> <- etc,
         <<block_align::16-little, etc::binary>> <- etc,
         <<bits_per_sample::16-little, etc::binary>> <- etc,
         module <- %__MODULE__{
           bits_per_sample: bits_per_sample,
           block_align: block_align,
           byte_rate: byte_rate,
           channels: channels,
           sample_rate: sample_rate
         },
         :ok <- validate(module) do
      {:ok, module, etc}
    else
      etc when is_binary(etc) -> {:error, "unexpected EOF"}
      error -> error
    end
  end
end
