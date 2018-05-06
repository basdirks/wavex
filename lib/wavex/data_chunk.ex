defmodule Wavex.DataChunk do
  @moduledoc """
  Reading a data chunk.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedID}
  alias Wavex.Utils

  defstruct [:size, :data]

  @type t :: %__MODULE__{size: non_neg_integer, data: binary}

  @doc ~S"""
  Read a data chunk.

  ## Examples

  [sapp.org, 2018-04-30, Microsoft WAVE soundfile format](http://soundfile.sapp.org/doc/WaveFormat/)

      iex> Wavex.DataChunk.read(<<
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x02, 0x00, 0x00, 0x00, #  2
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>, 4)
      {:ok, %Wavex.DataChunk{size: 2, data: <<0, 0, 0, 0, 0, 0, 0, 0>>}}

  """
  @spec read(binary, non_neg_integer) :: {:ok, t} | {:error, UnexpectedEOF.t() | UnexpectedID.t()}
  def read(binary, block_align)
      when is_binary(binary) and is_integer(block_align) and block_align > 0 do
    with {:ok, etc} <- Utils.read_id(binary, "data"),
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
