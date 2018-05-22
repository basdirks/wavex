defmodule Wavex.Utils do
  @moduledoc """
  Miscellaneous utilities.
  """

  @doc """
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
