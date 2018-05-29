defmodule Wavex.Chunk.Data do
  @moduledoc """
  A data chunk.
  """

  alias Wavex.Error.{
    UnexpectedEOF,
    UnexpectedFourCC
  }

  alias Wavex.FourCC

  @enforce_keys [
    :size,
    :data
  ]

  defstruct [
    :size,
    :data
  ]

  @type t :: %__MODULE__{size: non_neg_integer, data: binary}

  @four_cc "data"

  @doc """
  The ID that identifies a data chunk.
  """
  @spec four_cc :: FourCC.t()
  def four_cc, do: @four_cc

  @doc ~S"""
  Read a data chunk.
  """
  @spec read(binary) :: {:ok, t, binary} | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(binary) do
    with <<
           data_id::binary-size(4),
           size::32-little,
           data::binary-size(size),
           etc::binary
         >> <- binary,
         :ok <- FourCC.verify(data_id, @four_cc) do
      {:ok, %__MODULE__{size: size, data: data}, etc}
    else
      binary when is_binary(binary) -> {:error, %UnexpectedEOF{}}
      error -> error
    end
  end
end
