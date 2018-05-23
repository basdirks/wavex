defmodule Wavex.ZSTR do
  @moduledoc """
  A ZSTR: a NULL-terminated string.
  """

  @doc """
  Read a `ZSTR` value.
  """
  @spec read(binary) :: binary
  def read(binary) when is_binary(binary), do: do_read(binary)

  @spec do_read(binary, binary) :: binary
  defp do_read(etc, read \\ <<>>)
  defp do_read(<<>>, read), do: String.reverse(read)
  defp do_read(<<0, _::binary>>, read), do: String.reverse(read)
  defp do_read(<<h, etc::binary>>, read), do: do_read(etc, <<h>> <> read)
end
