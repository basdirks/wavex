defmodule Wavex.Utils do
  @moduledoc """
  Reading binary data.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedID}

  @doc """
  Read a FourCC.
  """
  @spec read_fourCC(binary, binary) ::
          {:ok, binary} | {:error, UnexpectedID.t() | UnexpectedEOF.t()}
  def read_fourCC(<<id::binary-size(4), etc::binary>>, expected_id) do
    case id do
      ^expected_id -> {:ok, e(c)}
      _ -> {:error, %UnexpectedID{expected: expected_id, actual: id}}
    end
  end

  def read_id(_, _), do: {:error, %UnexpectedEOF{}}
end
