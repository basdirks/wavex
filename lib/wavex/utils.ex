defmodule Wavex.Utils do
  @moduledoc """
  Miscellaneous utilities.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}

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

      iex> Wavex.Utils.read_until_null(5, <<1, 2, 3, 4, 5, 6, 7, 8, 9>>)
      {:ok, <<1, 2, 3, 4, 5>>, <<6, 7, 8, 9>>}

      iex> Wavex.Utils.read_until_null(5, <<1, 2, 3, 4, 5, 6, 7, 8, 9>>)
      {:ok, <<1, 2, 3, 4, 5>>, <<6, 7, 8, 9>>}

      iex> Wavex.Utils.read_until_null(5, <<1, 2, 3>>)
      {:error, %Wavex.Error.UnexpectedEOF{}}

  """
  @spec read_until_null(non_neg_integer, binary) ::
          {:ok, binary, binary} | {:error, UnexpectedEOF.t()}
  def read_until_null(max_bytes, binary)
      when is_integer(max_bytes) and max_bytes >= 0 and is_binary(binary) do
    do_read_until_null(max_bytes, binary, <<>>)
  end

  @spec do_read_until_null(non_neg_integer, binary, binary) ::
          {:ok, binary, binary} | {:error, UnexpectedEOF.t()}
  defp do_read_until_null(0, etc, read), do: {:ok, String.reverse(read), etc}
  defp do_read_until_null(_, <<>>, _), do: {:error, %UnexpectedEOF{}}
  defp do_read_until_null(_, <<0, _::binary>> = etc, read), do: {:ok, String.reverse(read), etc}

  defp do_read_until_null(remaining_max_bytes, <<head, etc::binary>>, read) do
    do_read_until_null(remaining_max_bytes - 1, etc, <<head>> <> read)
  end
end
