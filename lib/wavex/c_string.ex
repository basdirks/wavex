defmodule Wavex.CString do
  @moduledoc """
  A C-String, or NULL-terminated string.
  """

  @doc """
  Read a `CString` value.
  """
  @spec read(binary) :: binary
  def read(binary) when is_binary(binary), do: do_read(binary)

  @spec do_read(binary, binary) :: binary
  defp do_read(etc, read \\ <<>>)
  defp do_read(<<0, _::binary>>, read), do: reverse(read)
  defp do_read(<<>>, read), do: reverse(read)
  defp do_read(<<h, etc::binary>>, read), do: do_read(etc, <<h, read::binary>>)

  @spec reverse(binary) :: binary
  defp reverse(<<>>), do: <<>>

  defp reverse(binary) do
    binary
    |> :binary.decode_unsigned(:little)
    |> :binary.encode_unsigned(:big)
  end
end
