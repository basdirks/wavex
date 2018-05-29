defmodule Wavex.Error.ByteRateMismatch do
  @moduledoc """
  A mismatched byte rate value.
  """

  alias Wavex.Error.ByteRateMismatch

  @enforce_keys [
    :expected,
    :actual
  ]

  defstruct [
    :expected,
    :actual
  ]

  @type t :: %__MODULE__{expected: non_neg_integer, actual: non_neg_integer}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%ByteRateMismatch{expected: expected, actual: actual}) do
      "expected byte rate #{expected}, got: #{actual}"
    end
  end
end
