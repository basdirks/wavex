defmodule Wavex.Chunk.Format do
  @moduledoc """
  A format chunk.
  """

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

  @doc """
  The ID that identifies a format chunk.
  """
  @spec four_cc :: FourCC.t()
  def four_cc, do: @four_cc

  @spec verify_size(non_neg_integer) :: :ok | {:error, {:unexpected_format_size, non_neg_integer}}
  defp verify_size(0x00000010), do: :ok
  defp verify_size(actual), do: {:error, {:unexpected_format_size, actual}}

  @spec verify_format(non_neg_integer) :: :ok | {:error, {:unsupported_format, non_neg_integer}}
  defp verify_format(0x0001), do: :ok
  defp verify_format(actual), do: {:error, {:unsupported_format, actual}}

  @spec verify_bits_per_sample(non_neg_integer) ::
          :ok | {:error, {:unsupported_bits_per_sample, non_neg_integer}}
  defp verify_bits_per_sample(actual) when actual in [0x0008, 0x0010, 0x0018], do: :ok
  defp verify_bits_per_sample(actual), do: {:error, {:unsupported_bits_per_sample, actual}}

  @spec verify_channels(non_neg_integer) :: :ok | {:error, :zero_channels}
  defp verify_channels(0x0000), do: {:error, :zero_channels}
  defp verify_channels(_), do: :ok

  @spec verify_block_align(non_neg_integer, non_neg_integer) ::
          :ok
          | {:error,
             {:unexpected_block_align, %{expected: non_neg_integer, actual: non_neg_integer}}}
  defp verify_block_align(expected, expected), do: :ok

  defp verify_block_align(expected, actual) do
    {:error, {:unexpected_block_align, %{expected: expected, actual: actual}}}
  end

  @spec verify_byte_rate(non_neg_integer, non_neg_integer) ::
          :ok
          | {:error,
             {:unexpected_byte_rate, %{expected: non_neg_integer, actual: non_neg_integer}}}
  defp verify_byte_rate(expected, expected), do: :ok

  defp verify_byte_rate(expected, actual) do
    {:error, {:unexpected_byte_rate, %{expected: expected, actual: actual}}}
  end

  @doc ~S"""
  Read a format chunk.
  """
  @spec read(binary) ::
          {:ok, t, binary}
          | {:error,
             :unexpected_eof
             | :zero_channels
             | {:unexpected_block_align, %{expected: non_neg_integer, actual: non_neg_integer}}
             | {:unexpected_byte_rate, %{expected: non_neg_integer, actual: non_neg_integer}}
             | {:unexpected_format_size, non_neg_integer}
             | {:unexpected_four_cc, %{actual: FourCC.t(), expected: FourCC.t()}}
             | {:unsupported_bits_per_sample, non_neg_integer}
             | {:unsupported_format, non_neg_integer}}
  def read(binary) do
    with <<
           # 0 - 3
           fmt_id::binary-size(4),
           # 4 - 7
           size::32-little,
           # 8 - 9
           format::16-little,
           # 10 - 11
           channels::16-little,
           # 12 - 15
           sample_rate::32-little,
           # 16 - 19
           byte_rate::32-little,
           # 20 - 21
           block_align::16-little,
           # 22 - 23
           bits_per_sample::16-little,
           etc::binary
         >> <- binary,
         :ok <- FourCC.verify(fmt_id, @four_cc),
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
    else
      binary when is_binary(binary) -> {:error, :unexpected_eof}
      error -> error
    end
  end
end
