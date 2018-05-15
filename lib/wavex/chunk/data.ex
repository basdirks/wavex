defmodule Wavex.Chunk.Data do
  @moduledoc """
  Read a data chunk.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}
  alias Wavex.Utils

  @enforce_keys [
    :size,
    :data
  ]

  defstruct [
    :size,
    :data
  ]

  @type t :: %__MODULE__{size: non_neg_integer, data: binary}

  @doc ~S"""
  Read a data chunk.

  ## Examples

  Reading a data chunk of size `8`:

      iex> Wavex.Chunk.Data.read(<<
      ...>   0x64, 0x61, 0x74, 0x61, #  d     a     t     a
      ...>   0x08, 0x00, 0x00, 0x00, #  8
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:ok, %Wavex.Chunk.Data{size: 8, data: <<0, 0, 0, 0, 0, 0, 0, 0>>}, ""}

  ## Caveats

  Bytes 1-4 must read `"data"` to indicate a data chunk. A different value
  results in an error:

      iex> Wavex.Chunk.Data.read(<<
      ...>   0x64, 0x61, 0x74, 0x20, #  d     a     t     \s 
      ...>   0x08, 0x00, 0x00, 0x00, #  8
      ...>   0x00, 0x00, 0x00, 0x00, #  0
      ...>   0x00, 0x00, 0x00, 0x00  #  0
      ...> >>)
      {:error, %Wavex.Error.UnexpectedFourCC{expected: "data", actual: "dat "}}

  """
  @spec read(binary) :: {:ok, t, binary} | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(<<
        data_id::binary-size(4),
        size::32-little,
        data::binary-size(size),
        etc::binary
      >>) do
    with :ok <- Utils.verify_four_cc(data_id, "data") do
      {:ok, %__MODULE__{size: size, data: data}, etc}
    end
  end

  def read(binary) when is_binary(binary), do: {:error, %UnexpectedEOF{}}
end
