defmodule Wavex.Utils do
  @moduledoc """
  Reading binary data.
  """

  @unexpected_chunk_id &"expected chunk id '#{&1}', got: '#{&2}'"
  @verification_error &"expected #{&1} '#{&2}', got: '#{&3}'"

  @spec verify(binary, t, t) :: :ok | {:error, binary} when t: var
  def verify(_, value, value), do: :ok
  def verify(label, expected, actual), do: {:error, @verification_error(label, expected, actual)}

  @spec read_id(binary, binary) :: {:ok | :error, binary}
  def read_id(<<id::binary-size(4), etc::binary>>, expected_id) do
    case id do
      ^expected_id -> {:ok, etc}
      _ -> {:error, @unexpected_chunk_id(expected_id, id)}
    end
  end
end
