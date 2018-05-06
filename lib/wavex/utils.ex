defmodule Wavex.Utils do
  @moduledoc """
  Reading binary data.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}

  @doc """
  Read a FourCC (four character code).
  """
  @spec read_fourCC(binary, binary) ::
          {:ok, binary} | {:error, UnexpectedFourCC.t() | UnexpectedEOF.t()}
  def read_fourCC(<<code::binary-size(4), etc::binary>>, expected_code) do
    case code do
      ^expected_code -> {:ok, etc}
      _ -> {:error, %UnexpectedFourCC{expected: expected_code, actual: code}}
    end
  end

  def read_fourCC(_, _), do: {:error, %UnexpectedEOF{}}
end
