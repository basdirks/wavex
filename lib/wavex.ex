defmodule Wavex do
  @moduledoc """
  Read LPCM WAVE data.
  """

  alias Wavex.Chunk.{Data, Format, RIFF}
  alias Wavex.Error
  alias Wavex.Error.RIFFSizeMismatch

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

  @spec verify_riff_size(non_neg_integer, binary) :: :ok | {:error, RIFFSizeMismatch.t()}
  defp verify_riff_size(actual, binary) do
    case byte_size(binary) - 8 do
      ^actual -> :ok
      expected -> {:error, %RIFFSizeMismatch{expected: expected, actual: actual}}
    end
  end

  @doc """
  The duration of a wave file in milliseconds.

  ## Examples

  Calculating the duration of 100000 samples at 88200b/s.

      iex> Wavex.duration(%Wavex{
      ...>   data: %Wavex.Chunk.Data{
      ...>     data:
      ...>       0
      ...>       |> List.duplicate(100_000)
      ...>       |> List.to_string(),
      ...>     size: 100_000
      ...>   },
      ...>   format: %Wavex.Chunk.Format{
      ...>     bits_per_sample: 8,
      ...>     block_align: 2,
      ...>     byte_rate: 88_200,
      ...>     channels: 2,
      ...>     sample_rate: 44_100
      ...>   },
      ...>   riff: %Wavex.Chunk.RIFF{size: 100_036}
      ...> })
      1133.7868480725624

  Calculating the duration of 100000 samples at 176400b/s.

      iex> Wavex.duration(%Wavex{
      ...>   data: %Wavex.Chunk.Data{
      ...>     data:
      ...>       0
      ...>       |> List.duplicate(100_000)
      ...>       |> List.to_string(),
      ...>     size: 100_000
      ...>   },
      ...>   format: %Wavex.Chunk.Format{
      ...>     bits_per_sample: 16,
      ...>     block_align: 4,
      ...>     byte_rate: 176_400,
      ...>     channels: 2,
      ...>     sample_rate: 44_100
      ...>   },
      ...>   riff: %Wavex.Chunk.RIFF{size: 100_036}
      ...> })
      566.8934240362812

  """
  @spec duration(t) :: number
  def duration(%__MODULE__{
        data: %Data{size: size},
        format: %Format{byte_rate: byte_rate}
      }) do
    size / byte_rate * 1000
  end

  @doc ~S"""
  Map over the data of a `%Wavex{}` value.

  ## Examples

  Mapping over an 8-bit `%Wavex{}` value.

      iex> wave = %Wavex{
      ...>   riff: %RIFF{
      ...>     size: 60
      ...>   },
      ...>   format: %Format{
      ...>     bits_per_sample: 8,
      ...>     block_align: 2,
      ...>     byte_rate: 88_200,
      ...>     channels: 2,
      ...>     sample_rate: 44_100
      ...>   },
      ...>   data: %Data{
      ...>     size: 24,
      ...>     data: <<
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00
      ...>     >>
      ...>   }
      ...> }
      iex> wave = Wavex.map(wave, &(&1 + 0x12))
      iex> wave.data.data
      <<
        0x12, 0x12, 0x12, 0x12,
        0x12, 0x12, 0x12, 0x12,
        0x12, 0x12, 0x12, 0x12,
        0x12, 0x12, 0x12, 0x12,
        0x12, 0x12, 0x12, 0x12,
        0x12, 0x12, 0x12, 0x12
      >>

  Mapping over a 16-bit `%Wavex{}` value.

      iex> wave = %Wavex{
      ...>   riff: %RIFF{
      ...>     size: 60
      ...>   },
      ...>   format: %Format{
      ...>     bits_per_sample: 16,
      ...>     block_align: 4,
      ...>     byte_rate: 176_400,
      ...>     channels: 2,
      ...>     sample_rate: 44_100
      ...>   },
      ...>   data: %Data{
      ...>     size: 24,
      ...>     data: <<
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00
      ...>     >>
      ...>   }
      ...> }
      iex> wave = Wavex.map(wave, &(&1 - 0x1234))
      iex> wave.data.data
      <<
        -0x1234::16-signed-little, -0x1234::16-signed-little,
        -0x1234::16-signed-little, -0x1234::16-signed-little,
        -0x1234::16-signed-little, -0x1234::16-signed-little,
        -0x1234::16-signed-little, -0x1234::16-signed-little,
        -0x1234::16-signed-little, -0x1234::16-signed-little,
        -0x1234::16-signed-little, -0x1234::16-signed-little
      >>

  Mapping over a 24-bit `%Wavex{}` value.

      iex> wave = %Wavex{
      ...>   riff: %RIFF{
      ...>     size: 60
      ...>   },
      ...>   format: %Format{
      ...>     bits_per_sample: 24,
      ...>     block_align: 4,
      ...>     byte_rate: 176_400,
      ...>     channels: 2,
      ...>     sample_rate: 44_100
      ...>   },
      ...>   data: %Data{
      ...>     size: 24,
      ...>     data: <<
      ...>       0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      ...>       0x00, 0x00, 0x00, 0x00, 0x00, 0x00
      ...>     >>
      ...>   }
      ...> }
      iex> wave = Wavex.map(wave, &(&1 + 0x123456))
      iex> wave.data.data
      <<
        0x123456::24-signed-little, 0x123456::24-signed-little,
        0x123456::24-signed-little, 0x123456::24-signed-little,
        0x123456::24-signed-little, 0x123456::24-signed-little,
        0x123456::24-signed-little, 0x123456::24-signed-little
      >>

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

  @spec map8(binary, (integer -> integer), binary) :: binary
  defp map8(binary, function, acc \\ <<>>)

  defp map8(<<sample, etc::binary>>, function, acc) do
    map8(etc, function, <<function.(sample)>> <> acc)
  end

  defp map8(<<>>, _, acc), do: String.reverse(acc)

  @spec map16(binary, (integer -> integer), binary) :: binary
  defp map16(binary, function, acc \\ <<>>)

  defp map16(<<sample::16-signed-little, etc::binary>>, function, acc) do
    map16(etc, function, <<function.(sample)::16-signed-big>> <> acc)
  end

  defp map16(<<>>, _, acc), do: String.reverse(acc)

  @spec map24(binary, (integer -> integer), binary) :: binary
  defp map24(binary, function, acc \\ <<>>)

  defp map24(<<sample::24-signed-little, etc::binary>>, function, acc) do
    map24(etc, function, <<function.(sample)::24-signed-big>> <> acc)
  end

  defp map24(<<>>, _, acc), do: String.reverse(acc)

  @doc ~S"""
  Read LPCM WAVE data.

  For more details, see `Wavex.Chunk.RIFF.read/1`, `Wavex.Chunk.Format.read/1`,
  and `Wavex.Chunk.Data.read/1`.

  ## Examples

  Reading a 16-bit stereo 88200b/s LPCM file:
      
      iex> Wavex.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x2C, 0x00, 0x00, 0x00, #  44
      ...>   0x57, 0x41, 0x56, 0x45, #  W     A     V     E
      ...>   0x66, 0x6D, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x02, 0x00, #  1           2
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x88, 0x58, 0x01, 0x00, #  88200
      ...>   0x04, 0x00, 0x10, 0x00, #  4           16
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x08, 0x00, 0x00, 0x00, #  8
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:ok,
       %Wavex{
         data: %Wavex.Chunk.Data{
           data: <<0, 0, 0, 0, 0, 0, 0, 0>>,
           size: 8
         },
         format: %Wavex.Chunk.Format{
           bits_per_sample: 16,
           block_align: 4,
           byte_rate: 88_200,
           channels: 2,
           sample_rate: 22_050
         },
         riff: %Wavex.Chunk.RIFF{size: 44}
       }}

  Reading a 16-bit mono 22050/s LPCM file:

      iex> Wavex.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x28, 0x00, 0x00, 0x00, #  40
      ...>   0x57, 0x41, 0x56, 0x45, #  W     A     V     E
      ...>   0x66, 0x6D, 0x74, 0x20, #  f     m     t     \s
      ...>   0x10, 0x00, 0x00, 0x00, #  16
      ...>   0x01, 0x00, 0x01, 0x00, #  1           1
      ...>   0x11, 0x2B, 0x00, 0x00, #  11025
      ...>   0x22, 0x56, 0x00, 0x00, #  22050
      ...>   0x02, 0x00, 0x10, 0x00, #  2           16
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x04, 0x00, 0x00, 0x00, #  4
      ...>   0x00, 0x00, 0xFE, 0xFF  #  0     0     254   255
      ...> >>)
      {:ok,
       %Wavex{
         data: %Wavex.Chunk.Data{data: <<0, 0, 254, 255>>, size: 4},
         format: %Wavex.Chunk.Format{
           bits_per_sample: 16,
           block_align: 2,
           byte_rate: 22_050,
           channels: 1,
           sample_rate: 11_025
         },
         riff: %Wavex.Chunk.RIFF{size: 40}
       }}

  """
  @spec read(binary) :: {:ok, t} | {:error, Error.t()}
  def read(binary) when is_binary(binary) do
    with {:ok, %RIFF{size: riff_size} = riff, etc} <- RIFF.read(binary),
         :ok <- verify_riff_size(riff_size, binary),
         {:ok, %Format{} = format, etc} <- Format.read(etc),
         {:ok, %Data{} = data} <- Data.read(etc) do
      {:ok, %Wavex{riff: riff, format: format, data: data}}
    end
  end
end
