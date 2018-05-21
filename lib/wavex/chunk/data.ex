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
