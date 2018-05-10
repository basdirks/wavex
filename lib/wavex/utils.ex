defmodule Wavex.Utils do
  @moduledoc """
  Miscellaneous utilities.
  """

  alias Wavex.Error.UnexpectedFourCC

  @doc """
  Verify a FourCC (four character code).
  """
  @spec verify_four_cc(non_neg_integer, non_neg_integer) :: :ok | {:error, UnexpectedFourCC.t()}
  def verify_four_cc(expected, expected), do: :ok

  def verify_four_cc(actual, expected) do
    {:error, %UnexpectedFourCC{expected: expected, actual: actual}}
  end
end
