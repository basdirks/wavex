defmodule Wavex do
  @moduledoc """
  Read LPCM WAVE data.
  """

  alias Wavex.FourCC

  alias Wavex.Chunk.{
    BAE,
    Data,
    Format,
    RIFF
  }

  @enforce_keys [
    :riff,
    :format,
    :data
  ]

  defstruct [
    :riff,
    :format,
    :data,
    :bae
  ]

  @type t :: %__MODULE__{
          riff: RIFF.t(),
          format: Format.t(),
          data: Data.t(),
          bae: BAE.t() | nil
        }

  @chunks_required %{
    Format.four_cc() => {Format, :format},
    Data.four_cc() => {Data, :data}
  }

  @chunks_optional %{
    BAE.four_cc() => {BAE, :bae}
  }

  @chunks Map.merge(@chunks_optional, @chunks_required)

  @spec map8(binary, (non_neg_integer -> non_neg_integer), binary) :: binary
  defp map8(binary, function, acc \\ <<>>)

  defp map8(<<sample, etc::binary>>, function, acc),
    do: map8(etc, function, <<function.(sample)>> <> acc)

  defp map8(<<>>, _, acc), do: String.reverse(acc)

  @spec map16(binary, (integer -> integer), binary) :: binary
  defp map16(binary, function, acc \\ <<>>)

  defp map16(<<sample::16-signed-little, etc::binary>>, function, acc),
    do: map16(etc, function, <<function.(sample)::16-signed-big>> <> acc)

  defp map16(<<>>, _, acc), do: String.reverse(acc)

  @spec map24(binary, (integer -> integer), binary) :: binary
  defp map24(binary, function, acc \\ <<>>)

  defp map24(<<sample::24-signed-little, etc::binary>>, function, acc),
    do: map24(etc, function, <<function.(sample)::24-signed-big>> <> acc)

  defp map24(<<>>, _, acc), do: String.reverse(acc)

  @spec skip_chunk(binary) :: {:ok, binary} | {:error, :unexpected_eof}
  defp skip_chunk(binary) when is_binary(binary) do
    with <<size::32-little, etc::binary>> <- binary,
         size <- round(size / 2) * 2,
         <<_::binary-size(size), etc::binary>> <- etc do
      {:ok, etc}
    else
      _ -> {:error, :unexpected_eof}
    end
  end

  @spec read_chunks(binary, map) :: {:ok, map} | {:error, :unexpected_eof}
  defp read_chunks(binary, chunks \\ %{})
  defp read_chunks(<<>>, chunks), do: {:ok, chunks}

  defp read_chunks(<<four_cc::binary-size(4), etc::binary>> = binary, chunks) do
    case Map.fetch(@chunks, four_cc) do
      {:ok, {module, key}} ->
        with {:ok, chunk, etc} <- module.read(binary) do
          read_chunks(etc, Map.put(chunks, key, chunk))
        end

      _ ->
        with {:ok, etc} <- skip_chunk(etc) do
          read_chunks(etc, chunks)
        end
    end
  end

  defp read_chunks(binary, _) when is_binary(binary), do: {:error, :unexpected_eof}

  @spec verify_riff_size(non_neg_integer, binary) ::
          :ok
          | {:error,
             {:unexpected_riff_size, %{expected: non_neg_integer, actual: non_neg_integer}}}
  defp verify_riff_size(actual, binary) do
    case byte_size(binary) - 0x0008 do
      ^actual -> :ok
      expected -> {:error, {:unexpected_riff_size, %{expected: expected, actual: actual}}}
    end
  end

  @spec verify_chunks(map) :: :ok | {:error, {:missing_chunks, [atom]}}
  defp verify_chunks(chunks) do
    chunks_missing =
      for {_, {module, key}} <- @chunks_required, !match?(%{^key => %^module{}}, chunks) do
        module
      end

    case chunks_missing do
      [] -> :ok
      missing -> {:error, {:missing_chunks, missing}}
    end
  end

  @doc """
  The duration of a wave file in seconds.
  """
  @spec duration(t) :: number
  def duration(%__MODULE__{
        data: %Data{size: size},
        format: %Format{byte_rate: byte_rate}
      }) do
    size / byte_rate
  end

  @doc ~S"""
  Map over the data of a `Wavex` value.
  """
  @spec map(t, (integer -> integer)) :: t
  def map(
        %__MODULE__{
          data: %Data{data: data} = data_chunk,
          format: %Format{bits_per_sample: bits_per_sample}
        } = wave,
        function
      ) do
    data =
      case bits_per_sample do
        0x08 -> map8(data, function)
        0x10 -> map16(data, function)
        0x18 -> map24(data, function)
      end

    %__MODULE__{wave | data: %Data{data_chunk | data: data}}
  end

  @doc ~S"""
  Read LPCM WAVE data.
  """
  @spec read(binary) ::
          {:ok, t}
          | {:error,
             :unexpected_eof
             | :zero_channels
             | {:missing_chunks, [atom]}
             | {:unexpected_block_align, %{expected: non_neg_integer, actual: non_neg_integer}}
             | {:unexpected_byte_rate, %{expected: non_neg_integer, actual: non_neg_integer}}
             | {:unexpected_format_size, non_neg_integer}
             | {:unexpected_four_cc, %{actual: FourCC.t(), expected: FourCC.t()}}
             | {:unsupported_bae_version, non_neg_integer}
             | {:unsupported_bits_per_sample, non_neg_integer}
             | {:unsupported_format, non_neg_integer}
             | {:unreadable_date, BAE.date_binary()}
             | {:unreadable_time, BAE.time_binary()}}
  def read(binary) when is_binary(binary) do
    with {:ok, %RIFF{size: riff_size} = riff, etc} <- RIFF.read(binary),
         :ok <- verify_riff_size(riff_size, binary),
         {:ok, chunks} <- read_chunks(etc),
         :ok <- verify_chunks(chunks) do
      {:ok, struct(Wavex, Map.put(chunks, :riff, riff))}
    end
  end
end
