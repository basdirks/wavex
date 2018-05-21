defmodule Wavex do
  @moduledoc """
  Read LPCM WAVE data.
  """

  alias Wavex.Chunk.{Data, Format, RIFF}
  alias Wavex.Error
  alias Wavex.Error.{MissingChunks, RIFFSizeMismatch, UnexpectedEOF}

  @enforce_keys [
    :riff,
    :format,
    :data
  ]

  defstruct [
    :riff,
    :format,
    :data
  ]

  @type t :: %__MODULE__{
          riff: RIFF.t(),
          format: Format.t(),
          data: Data.t()
        }

  @chunks %{
    "fmt " => {Format, :format},
    "data" => {Data, :data}
  }

  @spec map8(binary, (integer -> integer), binary) :: binary
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

  @spec skip_chunk(binary) :: {:ok, binary} | {:error, UnexpectedEOF.t()}
  defp skip_chunk(binary) when is_binary(binary) do
    with <<size::32-little, etc::binary>> <- binary,
         size <- round(size / 2) * 2,
         <<_::binary-size(size), etc::binary>> <- etc do
      {:ok, etc}
    else
      _ -> {:error, %UnexpectedEOF{}}
    end
  end

  @spec read_chunks(binary, map) :: {:ok, map} | {:error, UnexpectedEOF.t()}
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

  defp read_chunks(binary, _) when is_binary(binary), do: {:error, %UnexpectedEOF{}}

  @spec verify_riff_size(non_neg_integer, binary) :: :ok | {:error, RIFFSizeMismatch.t()}
  defp verify_riff_size(actual, binary) do
    case byte_size(binary) - 8 do
      ^actual -> :ok
      expected -> {:error, %RIFFSizeMismatch{expected: expected, actual: actual}}
    end
  end

  @spec verify_chunks(map) :: :ok | {:error, MissingChunks.t()}
  defp verify_chunks(%{format: %Format{}, data: %Data{}}), do: :ok
  defp verify_chunks(%{format: %Format{}}), do: {:error, %MissingChunks{missing: [Data]}}
  defp verify_chunks(%{data: %Data{}}), do: {:error, %MissingChunks{missing: [Format]}}
  defp verify_chunks(%{}), do: {:error, %MissingChunks{missing: [Data, Format]}}

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
  Map over the data of a `%Wavex{}` value.
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
        8 -> map8(data, function)
        16 -> map16(data, function)
        24 -> map24(data, function)
      end

    %__MODULE__{wave | data: %Data{data_chunk | data: data}}
  end

  @spec size(t) :: non_neg_integer
  def size(%Wavex{riff: %RIFF{size: size}}), do: size + 8

  @doc ~S"""
  Read LPCM WAVE data.
  """
  @spec read(binary) :: {:ok, t} | {:error, Error.t()}
  def read(binary) when is_binary(binary) do
    with {:ok, %RIFF{size: riff_size} = riff, etc} <- RIFF.read(binary),
         :ok <- verify_riff_size(riff_size, binary),
         {:ok, chunks} <- read_chunks(etc),
         :ok <- verify_chunks(chunks) do
      {:ok, struct(Wavex, Map.put(chunks, :riff, riff))}
    end
  end
end
