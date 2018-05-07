defmodule Wavex.RIFFHeader do
  @moduledoc """
  Reading a RIFF header.

  The RIFF header is the first chunk in a WAVE file, and normally consists of:

  - the `"RIFF"` FourCC,
  - the file size,
  - the `"WAVE"` FourCC.

  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}
  alias Wavex.Utils

  defstruct [:size]

  @type t :: %__MODULE__{size: pos_integer}

  @expected_riff_four_cc "RIFF"
  @expected_wave_four_cc "WAVE"

  @doc ~S"""
  Read a RIFF header.

  ## Examples

      iex> Wavex.RIFFHeader.read(<<
      ...>   0x52, 0x49, 0x46, 0x46, #  R     I     F     F
      ...>   0x24, 0x08, 0x00, 0x00, #  2084
      ...>   0x57, 0x41, 0x56, 0x45  #  W     A     V     E
      ...> >>)
      {:ok, %Wavex.RIFFHeader{size: 2084}, ""}

  ## Caveats

  ### "RIFF" FourCC

  Bytes 1-4 must read `"RIFF"` to indicate the Resource Interchange File Format.
  A different value results in an error.

      iex> Wavex.RIFFHeader.read(<<"RIFX", 0, 0, 0, 0, "WAVE">>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "RIFF", actual: "RIFX"}}

  ### "WAVE" FourCC

  Bytes 9-12 must read `"WAVE"` to indicate a waveform audio file. A different
  value results in an error.

      iex> Wavex.RIFFHeader.read(<<"RIFF", 0, 0, 0, 0, "AVI ">>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "WAVE", actual: "AVI "}}

  ### Header size

  A binary must be at least 12 bytes to contain a RIFF header.

      iex> Wavex.RIFFHeader.read(<<"RIFF", 0, 0>>)
      {:error, %Wavex.Error.UnexpectedEOF{}}

  Generally, the following holds for any `x`:

  ```elixir
  not is_binary(x) or String.length(x) >= 12 or
    Wavex.RIFFHeader.read(x) == %Wavex.Error.UnexpectedEOF{}
  ```

  """

  @spec read(binary) :: {:ok, t, binary} | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(binary) when is_binary(binary) do
    with {:ok, etc} <- Utils.read_fourCC(binary, @expected_riff_four_cc),
         <<size::32-little, etc::binary>> <- etc,
         {:ok, etc} <- Utils.read_fourCC(etc, @expected_wave_four_cc) do
      {:ok, %__MODULE__{size: size}, etc}
    else
      value when is_binary(value) -> {:error, %UnexpectedEOF{}}
      {:error, _} = error -> error
    end
  end
end
