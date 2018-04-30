defmodule Wavex.DataChunk do
  @moduledoc false

  alias Wavex.Utils

  defstruct [:size, :data]

  @type t :: %__MODULE__{}

  @spec read(binary) :: {:ok, t} | {:error, binary}
  def read(binary) when is_binary(binary) do
    with {:ok, etc} <- Utils.read_id(binary, "data"),
         <<size::32-little, etc::binary>> <- etc,
         :ok <- Utils.verify("data length", String.length(etc), 8 * size) do
      {:ok, %__MODULE__{size: size, data: etc}}
    else
      etc when is_binary(etc) -> {:error, "unexpected EOF"}
      error -> error
    end
  end
end
