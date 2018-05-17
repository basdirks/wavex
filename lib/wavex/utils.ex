defmodule Wavex.Utils do
  @moduledoc """
  Miscellaneous utilities.
  """

  alias Wavex.Error.UnexpectedFourCC

  @doc """
  Verify a FourCC (four character code).

  ## Examples

      iex> Wavex.Utils.verify_four_cc("RIFF", "RIFF")
      :ok

      iex> Wavex.Utils.verify_four_cc("RIFX", "RIFF")
      {:error, %UnexpectedFourCC{expected: "RIFF", actual: "RIFX"}}

  """
  @spec verify_four_cc(<<_::32>>, <<_::32>>) :: :ok | {:error, UnexpectedFourCC.t()}
  def verify_four_cc(<<actual::binary-size(4)>>, <<expected::binary-size(4)>>) do
    case actual do
      ^expected -> :ok
      _ -> {:error, %UnexpectedFourCC{expected: expected, actual: actual}}
    end
  end

  @doc ~S"""
  Read `max_bytes` bytes, or until a null byte is encountered.

  ## Examples

      iex> Wavex.Utils.take_until_null(<<1, 2, 3, 4, 5, 6, 7, 8, 9>>)
      <<1, 2, 3, 4, 5, 6, 7, 8, 9>>

      iex> Wavex.Utils.take_until_null(<<1, 2, 0, 4, 5, 6, 7, 8, 9>>)
      <<1, 2>>

  """
  @spec take_until_null(binary) :: binary
  def take_until_null(binary) when is_binary(binary) do
    do_take_until_null(binary)
  end

  defp do_take_until_null(etc, read \\ <<>>)
  defp do_take_until_null(<<>>, read), do: String.reverse(read)
  defp do_take_until_null(<<0, _::binary>>, read), do: String.reverse(read)
  defp do_take_until_null(<<h, etc::binary>>, read), do: do_take_until_null(etc, <<h>> <> read)
end
