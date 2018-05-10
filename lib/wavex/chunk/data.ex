defmodule Wavex.Chunk.Data do
  @moduledoc """
  Reading a data chunk.

  A data chunk normally contains:

  - a `"data"` FourCC,
  - the size of the actual audio data,
  - the actual audio data.

  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}
  alias Wavex.Utils

  defstruct [:size, :data]

  @type t :: %__MODULE__{size: non_neg_integer, data: binary}

  @expected_data_four_cc "data"

  @doc ~S"""
  Read a data chunk.

  ## Examples

      iex> Wavex.Chunk.Data.read(<<
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x08, 0x00, 0x00, 0x00, #  8
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:ok, %Wavex.Chunk.Data{size: 8, data: <<0, 0, 0, 0, 0, 0, 0, 0>>}}

  ## Caveat

  ### "data" FourCC

  Bytes 1-4 must read `"data"` to indicate a data chunk. A different value
  results in an error.

      iex> Wavex.Chunk.Data.read(<<
      ...>   0x64, 0x61, 0x74, 0x20, #  d     a     t     \s 
      ...>   0x08, 0x00, 0x00, 0x00, #  8
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "data", actual: "dat "}}

  """
  @spec read(binary) :: {:ok, t} | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(<<
        data_four_cc::binary-size(4),
        size::32-little,
        data::binary-size(size),
        _::binary
      >>) do
    with :ok <- Utils.verify_four_cc(data_four_cc, @expected_data_four_cc) do
      {:ok, %__MODULE__{size: size, data: data}}
    end
  end

  def read(binary) when is_binary(binary), do: {:error, %UnexpectedEOF{}}
end
