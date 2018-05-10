defmodule Wavex.Chunk.Format do
  @moduledoc """
  Reading a format chunk.

  A format chunk normally contains information about the data that follows:

  - a `"fmt "` FourCC,
  - a format size,
  - a format,
  - the number of channels,
  - a sample rate,
  - a byte rate,
  - block alignment,
  - the bits per sample.

  """

  alias Wavex.Utils

  alias Wavex.Error.{
    BlockAlignMismatch,
    ByteRateMismatch,
    UnexpectedEOF,
    UnexpectedFormatSize,
    UnexpectedFourCC,
    UnsupportedBitsPerSample,
    UnsupportedFormat,
    ZeroChannels
  }

  defstruct [:channels, :sample_rate, :byte_rate, :block_align, :bits_per_sample]

  @type t :: %__MODULE__{
          channels: pos_integer,
          sample_rate: pos_integer,
          byte_rate: pos_integer,
          block_align: pos_integer,
          bits_per_sample: pos_integer
        }

  @expected_format_size 16
  @expected_format 1
  @expected_fmt_four_cc "fmt "
  @supported_bits_per_sample_values [8, 16, 24]

  @spec verify_size(non_neg_integer) :: :ok | {:error, UnexpectedFormatSize.t()}
  defp verify_size(@expected_format_size), do: :ok
  defp verify_size(actual), do: {:error, %UnexpectedFormatSize{actual: actual}}

  @spec verify_format(non_neg_integer) :: :ok | {:error, UnexpectedFormatSize.t()}
  defp verify_format(@expected_format), do: :ok
  defp verify_format(actual), do: {:error, %UnsupportedFormat{actual: actual}}

  @spec verify_bits_per_sample(non_neg_integer) :: :ok | {:error, UnsupportedBitsPerSample.t()}
  defp verify_bits_per_sample(actual)
       when actual in @supported_bits_per_sample_values do
    :ok
  end

  defp verify_bits_per_sample(actual) do
    {:error, %UnsupportedBitsPerSample{actual: actual}}
  end

  @spec verify_channels(non_neg_integer) :: :ok | {:error, ZeroChannels.t()}
  defp verify_channels(0), do: {:error, %ZeroChannels{}}
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

  ## Examples

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:ok,
      %Wavex.Chunk.Format{
        bits_per_sample: 16,
        block_align: 4,
        byte_rate: 88_200,
        channels: 2,
        sample_rate: 22_050
      }, ""}

  ## Caveats

  ### "fmt " FourCC

  Bytes 1-4 must read `"fmt "` to indicate a format chunk. A different value
  results in an error. The following example gives an error because bytes 1-4
  read `"data"` instead of `"fmt "`.

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "fmt ", actual: "data"}}

  ### Format size

  The format size at bytes 5-8 is expected to be `16`, the default format size
  for the LPCM format. The following example gives an error because the format
  size is `18` instead of `16`.

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x12, 0x00, 0x00, 0x00, #  18
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnexpectedFormatSize{actual: 18}}

  ### Format size

  The format at bytes 9-12 must be `0x0001` (LPCM), as other formats are not
  supported. The following example gives an error because the format is
  `0x0032` instead of `0x0001`.

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x32, 0x00, 0x02, 0x00, #  50          2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnsupportedFormat{actual: 0x0032}}

  """
  @spec read(binary) ::
          {:ok, t, binary}
          | {:error,
             BlockAlignMismatch.t()
             | ByteRateMismatch.t()
             | UnexpectedEOF.t()
             | UnexpectedFormatSize.t()
             | UnexpectedFourCC.t()
             | UnsupportedBitsPerSample.t()
             | UnsupportedFormat.t()
             | ZeroChannels.t()}
  def read(<<
        fmt_four_cc::binary-size(4),
        size::32-little,
        format::16-little,
        channels::16-little,
        sample_rate::32-little,
        byte_rate::32-little,
        block_align::16-little,
        bits_per_sample::16-little,
        etc::binary
      >>) do
    with :ok <- Utils.verify_four_cc(fmt_four_cc, @expected_fmt_four_cc),
         :ok <- verify_size(size),
         :ok <- verify_format(format),
         :ok <- verify_channels(channels),
         :ok <- verify_bits_per_sample(bits_per_sample),
         :ok <- verify_block_align(channels * div(bits_per_sample, 8), block_align),
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
