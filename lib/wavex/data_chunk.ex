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
      ...>   0x02, 0x00, 0x00, 0x00, #  2
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>, 4)
      {:ok, %Wavex.DataChunk{size: 2, data: <<0, 0, 0, 0, 0, 0, 0, 0>>}}

  ## Caveat

  ### "data" FourCC

  Bytes 1-4 must read `"data"` to indicate a data chunk. A different value
  results in an error.

      iex> Wavex.DataChunk.read(<<"dat ", 2, 0, 0, 0, 0, 0, 0>>, 1)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "data", actual: "dat "}}

  """
  @spec read(binary, non_neg_integer) ::
          {:ok, t} | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(binary, block_align)
      when is_binary(binary) and is_integer(block_align) and block_align > 0 do
    with {:ok, etc} <- Utils.read_fourCC(binary, @expected_data_four_cc),
         <<size::32-little, etc::binary>> <- etc,
         bytes <- size * block_align,
         <<data::binary-size(bytes), _::binary>> <- etc do
      {:ok, %__MODULE__{size: size, data: data}}
    else
      etc when is_binary(etc) -> {:error, %UnexpectedEOF{}}
      error -> error
    end
  end
end
