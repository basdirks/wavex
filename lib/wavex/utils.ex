defmodule Wavex.Utils do
  @moduledoc """
  Reading utilities.
  """

  @spec verify(binary, t, t) :: :ok | {:error, binary} when t: var
  def verify(_, a, a), do: :ok
  def verify(label, a, b), do: {:error, "expected #{label} '#{a}', got: '#{b}'"}

  @spec read_id(binary, binary) :: {:ok | :error, binary}
  def read_id(<<id::binary-size(4), etc::binary>>, expected_id) do
    case id do
      ^expected_id -> {:ok, etc}
      _ -> {:error, "expected chunk id '#{expected_id}', got: '#{id}'"}
    end
  end
end
