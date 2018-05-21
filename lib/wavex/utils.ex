defmodule Wavex.Utils do
  @moduledoc """
  Miscellaneous utilities.
  """

  alias Wavex.Error.UnexpectedFourCC

  @doc """
  Verify a FourCC (four character code).
  """
  @spec verify_four_cc(<<_::32>>, <<_::32>>) :: :ok | {:error, UnexpectedFourCC.t()}
  def verify_four_cc(<<actual::binary-size(4)>>, <<expected::binary-size(4)>>) do
    case actual do
      ^expected -> :ok
      _ -> {:error, %UnexpectedFourCC{expected: expected, actual: actual}}
    end
  end

  @doc ~S"""
  Take bytes until null is encountered.
  """
  @spec take_until_null(binary) :: binary
  def take_until_null(binary) when is_binary(binary), do: do_take_until_null(binary)

  @spec do_take_until_null(binary, binary) :: binary
  defp do_take_until_null(etc, read \\ <<>>)
  defp do_take_until_null(<<>>, read), do: String.reverse(read)
  defp do_take_until_null(<<0, _::binary>>, read), do: String.reverse(read)
  defp do_take_until_null(<<h, etc::binary>>, read), do: do_take_until_null(etc, <<h>> <> read)
end
