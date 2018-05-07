defmodule Wavex.FormatChunk do
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

  @spec read_size(binary) :: {:ok, binary} | {:error, UnexpectedFormatSize.t()}
  defp read_size(<<size::32-little, etc::binary>>) do
    case size do
      @expected_format_size -> {:ok, etc}
      _ -> {:error, %UnexpectedFormatSize{size: size}}
    end
  end

  @spec read_format(binary) :: {:ok, binary} | {:error, UnsupportedFormat.t()}
  defp read_format(<<format::16-little, etc::binary>>) do
    case format do
      @expected_format -> {:ok, etc}
      _ -> {:error, %UnsupportedFormat{format: format}}
    end
  end

  @spec verify_bits_per_sample(non_neg_integer) :: :ok | {:error, UnsupportedBitsPerSample.t()}
  defp verify_bits_per_sample(bits_per_sample)
       when bits_per_sample in @supported_bits_per_sample_values do
    :ok
  end

  defp verify_bits_per_sample(bits_per_sample) do
    {:error, %UnsupportedBitsPerSample{bits_per_sample: bits_per_sample}}
  end

  @spec verify_channels(non_neg_integer) :: :ok | {:error, ZeroChannels.t()}
  defp verify_channels(0), do: {:error, %ZeroChannels{}}
  defp verify_channels(_), do: :ok

  @spec verify_block_align(non_neg_integer, non_neg_integer) ::
          :ok | {:error, BlockAlignMismatch.t()}
  defp verify_block_align(block_align, block_align), do: :ok

  defp verify_block_align(expected_block_align, actual_block_align) do
    {:error, %BlockAlignMismatch{expected: expected_block_align, actual: actual_block_align}}
  end

  @spec verify_byte_rate(non_neg_integer, non_neg_integer) :: :ok | {:error, ByteRateMismatch.t()}
  defp verify_byte_rate(block_align, block_align), do: :ok

  defp verify_byte_rate(expected_byte_rate, actual_byte_rate) do
    {:error, %ByteRateMismatch{expected: expected_byte_rate, actual: actual_byte_rate}}
  end

  @doc ~S"""
  Validate a format chunk.

  ## Examples

      iex> Wavex.FormatChunk.validate(%Wavex.FormatChunk{
      ...>   bits_per_sample: 16,
      ...>   block_align: 4,
      ...>   byte_rate: 88_200,
      ...>   channels: 2,
      ...>   sample_rate: 22_050
      ...> })
      :ok

  ### Channels

  The number of `channels` must be positive. The following example gives an
  error because `channels` is `0`.

      iex> Wavex.FormatChunk.validate(%Wavex.FormatChunk{
      ...>   bits_per_sample: 16,
      ...>   block_align: 4,
      ...>   byte_rate: 88_200,
      ...>   channels: 0,
      ...>   sample_rate: 22_050
      ...> })
      {:error, %Wavex.Error.ZeroChannels{}}

  ### Bits per sample

  `bits_per_sample` must be equal to `8`, `16`, or `24`. The following example
  gives an error because `bits_per_sample` is `32`.

      iex> Wavex.FormatChunk.validate(%Wavex.FormatChunk{
      ...>   bits_per_sample: 32,
      ...>   block_align: 4,
      ...>   byte_rate: 88_200,
      ...>   channels: 2,
      ...>   sample_rate: 22_050
      ...> })
      {:error, %Wavex.Error.UnsupportedBitsPerSample{bits_per_sample: 32}}

  ### Block alignment

  `block_align` must be equal to `channels * bits_per_sample / 8`. The
  following example gives an error because `block_align` is `4` instead of
  `2 * 8 / 8 = 2`.

      iex> Wavex.FormatChunk.validate(%Wavex.FormatChunk{
      ...>   bits_per_sample: 8,
      ...>   block_align: 4,
      ...>   byte_rate: 88_200,
      ...>   channels: 2,
      ...>   sample_rate: 22_050
      ...> })
      {:error, %Wavex.Error.BlockAlignMismatch{expected: 2, actual: 4}}

  ### Byte rate

  `byte_rate` must be equal to `sample_rate * block_align`. The following
  example gives an error because `byte_rate` is `88200` instead of
  `22050 * 2 = 44100`.

      iex> Wavex.FormatChunk.validate(%Wavex.FormatChunk{
      ...>   bits_per_sample: 8,
      ...>   block_align: 2,
      ...>   byte_rate: 88_200,
      ...>   channels: 2,
      ...>   sample_rate: 22_050
      ...> })
      {:error, %Wavex.Error.ByteRateMismatch{expected: 44100, actual: 88200}}

  """
  @spec validate(t) :: :ok | {:error, binary}
  def validate(%__MODULE__{
        bits_per_sample: bits_per_sample,
        block_align: block_align,
        byte_rate: byte_rate,
        channels: channels,
        sample_rate: sample_rate
      }) do
    with :ok <- verify_channels(channels),
         :ok <- verify_bits_per_sample(bits_per_sample),
         :ok <- verify_block_align(channels * div(bits_per_sample, 8), block_align),
         :ok <- verify_byte_rate(sample_rate * block_align, byte_rate) do
      :ok
    else
      error -> error
    end
  end

  @doc ~S"""
  Read and validate a format chunk. See `Wavex.FormatChunk.validate/1` to see
  what is validated.

  ## Examples

      iex Wavex.FormatChunk.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:ok,
      %Wavex.FormatChunk{
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

      iex> Wavex.FormatChunk.read(<<
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

      iex> Wavex.FormatChunk.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x12, 0x00, 0x00, 0x00, #  18
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnexpectedFormatSize{size: 18}}

  ### Format size

  The format at bytes 9-12 must be `0x0001` (LPCM), as other formats are not
  supported. The following example gives an error because the format is
  `0x0032` instead of `0x0001`.

      iex> Wavex.FormatChunk.read(<<
      ...>   0x66, 0x6d, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x32, 0x00, 0x02, 0x00, #  50          2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00  #  4           16
      ...> >>)
      {:error, %Wavex.Error.UnsupportedFormat{format: 0x0032}}

  ### Internal consistency

  The resulting `%Wavex.FormatChunk{}` is checked for internal consistency
  with `Wavex.FormatChunk.validate/1`.

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
  def read(binary) when is_binary(binary) do
    with {:ok, etc} <- Utils.read_fourCC(binary, @expected_fmt_four_cc),
         {:ok, etc} <- read_size(etc),
         {:ok, etc} <- read_format(etc),
         <<
           channels::16-little,
           sample_rate::32-little,
           byte_rate::32-little,
           block_align::16-little,
           bits_per_sample::16-little,
           etc::binary
         >> <- etc,
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
      etc when is_binary(etc) -> {:error, %UnexpectedEOF{}}
      {:error, _} = error -> error
    end
  end
end
