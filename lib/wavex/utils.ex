defmodule Wavex.Utils do
  @moduledoc """
  Reading binary data.
  """

  defp unexpected_chunk_id(expected_chunk_id, actual_chunk_id) do
    "expected chunk id '#{expected_chunk_id}', got: '#{actual_chunk_id}'"
  end

  defp verification_error(label, expected, actual) do
    "expected #{label} '#{expected}', got: '#{actual}'"
  end

  @spec verify(binary, t, t) :: :ok | {:error, binary} when t: var
  def verify(_, value, value), do: :ok
  def verify(label, expected, actual), do: {:error, verification_error(label, expected, actual)}

  @spec read_id(binary, binary) :: {:ok | :error, binary}
  def read_id(<<id::binary-size(4), etc::binary>>, expected_id) do
    case id do
      ^expected_id -> {:ok, etc}
      _ -> {:error, unexpected_chunk_id(expected_id, id)}
    end
  end
end
