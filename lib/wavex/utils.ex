defmodule Wavex.Utils do
  @moduledoc """
  Reading binary data.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedID}

  @doc """
  Read a 4-byte id.
  """
  @spec read_id(binary, binary) :: {:ok, binary} | {:error, UnexpectedID.t() | UnexpectedEOF.t()}
  def read_id(<<id::binary-size(4), etc::binary>>, expected_id) do
    case id do
      ^expected_id -> {:ok, etc}
      _ -> {:error, %UnexpectedID{expected: expected_id, actual: id}}
    end
  end

  def read_id(_, _), do: {:error, %UnexpectedEOF{}}
end
