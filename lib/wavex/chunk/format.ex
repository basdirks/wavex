defmodule Wavex.Chunk.Format do
  @moduledoc """
  A format chunk.
  """

  alias Wavex.Error.{
    BlockAlignMismatch,
    ByteRateMismatch,
    UnexpectedEOF,
    UnexpectedFormatSize,
    UnexpectedFourCC,
    UnsupportedBitrate,
    UnsupportedFormat,
    ZeroChannels
  }

  alias Wavex.FourCC

  @enforce_keys [
    :channels,
    :sample_rate,
    :byte_rate,
    :block_align,
    :bits_per_sample
  ]

  defstruct [
    :channels,
    :sample_rate,
    :byte_rate,
    :block_align,
    :bits_per_sample
  ]

  @type t :: %__MODULE__{
          channels: pos_integer,
          sample_rate: pos_integer,
          byte_rate: pos_integer,
          block_align: pos_integer,
          bits_per_sample: pos_integer
        }

  @four_cc "fmt "

  @spec four_cc :: FourCC.t()
  def four_cc, do: @four_cc

  @spec verify_size(non_neg_integer) :: :ok | {:error, UnexpectedFormatSize.t()}
  defp verify_size(0x10), do: :ok
  defp verify_size(actual), do: {:error, %UnexpectedFormatSize{actual: actual}}

  @spec verify_format(non_neg_integer) :: :ok | {:error, UnsupportedFormat.t()}
  defp verify_format(0x01), do: :ok
  defp verify_format(actual), do: {:error, %UnsupportedFormat{actual: actual}}

  @spec verify_bits_per_sample(non_neg_integer) :: :ok | {:error, UnsupportedBitrate.t()}
  defp verify_bits_per_sample(actual) when actual in [0x08, 0x10, 0x18], do: :ok
  defp verify_bits_per_sample(actual), do: {:error, %UnsupportedBitrate{actual: actual}}

  @spec verify_channels(non_neg_integer) :: :ok | {:error, ZeroChannels.t()}
  defp verify_channels(0x00), do: {:error, %ZeroChannels{}}
  defp verify_channels(_), do: :ok

  @spec verify_block_align(non_neg_integer, non_neg_integer) ::
          :ok | {:error, BlockAlignMismatch.t()}
  defp verify_block_align(expected, expected), do: :ok

  defp verify_block_align(expected, actual) do
    {:error, %BlockAlignMismatch{expected: expected, actual: actual}}
  end

  @spec verify_byte_rate(non_neg_integer, non_neg_integer) :: :ok | {:error, ByteRateMismatch.t()}
  defp verify_byte_rate(expected, expected), do: :ok

  defp verify_byte_rate(expected, actual) do
    {:error, %ByteRateMismatch{expected: expected, actual: actual}}
  end

  @doc ~S"""
  Read a format chunk.
  """
  @spec read(binary) ::
          {:ok, t, binary}
          | {:error,
             BlockAlignMismatch.t()
             | ByteRateMismatch.t()
             | UnexpectedEOF.t()
             | UnexpectedFormatSize.t()
             | UnexpectedFourCC.t()
             | UnsupportedBitrate.t()
             | UnsupportedFormat.t()
             | ZeroChannels.t()}
  def read(<<
        fmt_id::binary-size(4),
        size::32-little,
        format::16-little,
        channels::16-little,
        sample_rate::32-little,
        byte_rate::32-little,
        block_align::16-little,
        bits_per_sample::16-little,
        etc::binary
      >>) do
    with :ok <- FourCC.verify(fmt_id, @four_cc),
         :ok <- verify_size(size),
         :ok <- verify_format(format),
         :ok <- verify_channels(channels),
         :ok <- verify_bits_per_sample(bits_per_sample),
         :ok <- verify_block_align(channels * div(bits_per_sample, 0x08), block_align),
         :ok <- verify_byte_rate(sample_rate * block_align, byte_rate) do
      {:ok,
       %__MODULE__{
         bits_per_sample: bits_per_sample,
         block_align: block_align,
         byte_rate: byte_rate,
         channels: channels,
         sample_rate: sample_rate
       }, etc}
    end
  end

  def read(binary) when is_binary(binary), do: {:error, %UnexpectedEOF{}}
end
