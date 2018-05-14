defmodule Wavex.Chunk.RIFF do
  @moduledoc """
  Read a RIFF chunk.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}
  alias Wavex.Utils

  @enforce_keys [:size]

  defstruct [:size]

  @type t :: %__MODULE__{size: pos_integer}

  @doc ~S"""
  Read a RIFF chunk.

  ## Examples

      iex> Wavex.Chunk.RIFF.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x24, 0x08, 0x00, 0x00, #  2084
      ...>   0x57, 0x41, 0x56, 0x45  #  W     A     V     E
      ...> >>)
      {:ok, %Wavex.Chunk.RIFF{size: 2084}, ""}

  ## Caveats

  Bytes 1-4 must read `"RIFF"` to indicate the Resource Interchange File Format.
  A different value results in an error.

      iex> Wavex.Chunk.RIFF.read(<<"RIFX", 0, 0, 0, 0, "WAVE">>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "RIFF", actual: "RIFX"}}

  Bytes 9-12 must read `"WAVE"` to indicate a waveform audio file. A different
  value results in an error.

      iex> Wavex.Chunk.RIFF.read(<<"RIFF", 0, 0, 0, 0, "AVI ">>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "WAVE", actual: "AVI "}}

  A binary must be at least 12 bytes to contain a RIFF chunk.

      iex> Wavex.Chunk.RIFF.read(<<"RIFF", 0, 0>>)
      {:error, %Wavex.Error.UnexpectedEOF{}}

  Generally, the following holds for any `x`:

  ```elixir
  not is_binary(x) or
    String.length(x) >= 12 or
    Wavex.Chunk.RIFF.read(x) == %Wavex.Error.UnexpectedEOF{}
  ```

  """

  @spec read(binary) ::
          {:ok, t, binary}
          | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(<<
        riff_id::binary-size(4),
        size::32-little,
        wave_id::binary-size(4),
        etc::binary
      >>) do
    with :ok <- Utils.verify_four_cc(riff_id, "RIFF"),
         :ok <- Utils.verify_four_cc(wave_id, "WAVE") do
      {:ok, %__MODULE__{size: size}, etc}
    end
  end

  def read(binary) when is_binary(binary), do: {:error, %UnexpectedEOF{}}
end