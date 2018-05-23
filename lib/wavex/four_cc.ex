defmodule Wavex.FourCC do
  @moduledoc """
  A FourCC (four character code).
  """

  alias Wavex.Error.UnexpectedFourCC

  @type t :: <<_::32>>

  @doc """
  Verify a FourCC.
  """
  @spec verify(t, t) :: :ok | {:error, UnexpectedFourCC.t()}
  def verify(<<actual::binary-size(4)>>, <<expected::binary-size(4)>>) do
    case actual do
      ^expected -> :ok
      _ -> {:error, %UnexpectedFourCC{expected: expected, actual: actual}}
    end
  end
end
