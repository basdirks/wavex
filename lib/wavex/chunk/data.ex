defmodule Wavex.Chunk.Data do
  @moduledoc """
  A data chunk.
  """

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
  @spec read(binary) ::
          {:ok, t, binary}
          | {:error,
             :unexpected_eof
             | {:unexpected_four_cc, %{actual: FourCC.t(), expected: FourCC.t()}}}
  def read(binary) do
    with <<
           # 0 - 3
           data_id::binary-size(4),
           # 4 - 7
           size::32-little,
           # 8 - ...
           data::binary-size(size),
           etc::binary
         >> <- binary,
         :ok <- FourCC.verify(data_id, @four_cc) do
      {:ok, %__MODULE__{size: size, data: data}, etc}
    else
      binary when is_binary(binary) -> {:error, :unexpected_eof}
      error -> error
    end
  end
end
