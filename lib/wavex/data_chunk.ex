defmodule Wavex.DataChunk do
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

      iex> Wavex.DataChunk.read(<<
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x08, 0x00, 0x00, 0x00, #  8
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:ok, %Wavex.DataChunk{size: 8, data: <<0, 0, 0, 0, 0, 0, 0, 0>>}}

  ## Caveat

  ### "data" FourCC

  Bytes 1-4 must read `"data"` to indicate a data chunk. A different value
  results in an error.

      iex> Wavex.DataChunk.read(<<"dat ", 2, 0, 0>>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "data", actual: "dat "}}

  """
  @spec read(binary) :: {:ok, t} | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(binary) when is_binary(binary) do
    with {:ok, etc} <- Utils.read_fourCC(binary, @expected_data_four_cc),
         <<size::32-little, etc::binary>> <- etc,
         <<data::binary-size(size), _::binary>> <- etc do
      {:ok, %__MODULE__{size: size, data: data}}
    else
      etc when is_binary(etc) -> {:error, %UnexpectedEOF{}}
      error -> error
    end
  end
end
