defmodule Wavex.Chunk.Format do
  @moduledoc """
  Read a format chunk.
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

  @spec verify_size(non_neg_integer) :: :ok | {:error, UnexpectedFormatSize.t()}
  defp verify_size(16), do: :ok
  defp verify_size(actual), do: {:error, %UnexpectedFormatSize{actual: actual}}

  @spec verify_format(non_neg_integer) :: :ok | {:error, UnsupportedFormat.t()}
  defp verify_format(1), do: :ok
  defp verify_format(actual), do: {:error, %UnsupportedFormat{actual: actual}}

  @spec verify_bits_per_sample(non_neg_integer) :: :ok | {:error, UnsupportedBitsPerSample.t()}
  defp verify_bits_per_sample(actual) when actual in [8, 16, 24], do: :ok
  defp verify_bits_per_sample(actual), do: {:error, %UnsupportedBitsPerSample{actual: actual}}

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

  ## Example

  Reading the format chunk of a 16-bit stereo 88.2kb/s LPCM file:

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

  Bytes 1-4 must read `"fmt "` to indicate a format chunk. The following
  example gives an error because bytes 1-4 read `"data"` instead of `"fmt "`:

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "fmt ", actual: "data"}}

  The format size at bytes 5-8 is expected to be `16`, the format size for the
  LPCM format. The following example gives an error because the format size is
  `18` instead of `16`:

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x12, 0x00, 0x00, 0x00, #  18
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnexpectedFormatSize{actual: 18}}

  The format at bytes 9-10 must be `0x0001` (LPCM), as other formats are not
  supported. The following example gives an error because the format is
  `0x0032` instead of `0x0001`:

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x32, 0x00, 0x02, 0x00, #  50          2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnsupportedFormat{actual: 0x0032}}

  The format at bytes 11-12 must not be `0`, because there has to be at least
  one channel. The following example gives an error because the number of
  channels is `0`:

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x00, 0x00, #  1           0
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.ZeroChannels{}}

  The byte rate at bytes 17-20 must be equal to `sample_rate * block_align`.
  The following example gives an error because `44100` is not equal to
  `22050 * 4 = 88200`:

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x44, 0xAC, 0x00, 0x00, #  44100
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.ByteRateMismatch{expected: 88200, actual: 44100}}

  The block alignment at bytes 21-22 must be equal to
  `channels * bits_per_sample / 8`. The following example gives an error
  because `2` is not equal to `2 * 16 / 8 = 4`:

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x02, 0x00, 0x10, 0x00  #  2           16
      ...> >>)
      {:error, %Wavex.Error.BlockAlignMismatch{expected: 4, actual: 2}}

  The bits per second at bytes 23-24 must be `8`, `16`, or `24`, as other bit
  rates are not supported. The following example gives an error because the
  bit rate is `32`:

      iex> Wavex.Chunk.Format.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x20, 0x00  #  4           32
      ...> >>)
      {:error, %Wavex.Error.UnsupportedBitsPerSample{actual: 32}}

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
    with :ok <- Utils.verify_four_cc(fmt_id, "fmt "),
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
