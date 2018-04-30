defmodule Wavex.FormatChunk do
  @moduledoc false

  alias Wavex.Utils

  defstruct [:channels, :sample_rate, :byte_rate, :block_align, :bits_per_sample]

  @type t :: %__MODULE__{}

  @spec read_size(binary) :: {:ok | :error, binary}
  defp read_size(<<size::32-little, etc::binary>>) do
    case size do
      16 -> {:ok, etc}
      _ -> {:error, "expected format size 16, got: #{size}"}
    end
  end

  @spec read_format(binary) :: {:ok | :error, binary}
  defp read_format(<<format::16-little, etc::binary>>) do
    case format do
      1 -> {:ok, etc}
      _ -> {:error, "expected format 1 (PCM), got: #{format}"}
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
