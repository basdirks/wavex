defmodule Wavex.FourCC do
  @moduledoc """
  A FourCC (four character code).
  """

  @type t :: <<_::32>>

  @doc """
  Verify a FourCC.
  """
  @spec verify(t, t) :: :ok | {:error, {:unexpected_four_cc, %{expected: t, actual: t}}}
  def verify(<<actual::binary-size(4)>>, <<expected::binary-size(4)>>) do
    case actual do
      ^expected -> :ok
      _ -> {:error, {:unexpected_four_cc, %{expected: expected, actual: actual}}}
    end
  end
end
