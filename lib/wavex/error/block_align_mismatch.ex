defmodule Wavex.Error.BlockAlignMismatch do
  @moduledoc """
  A mismatched block align value.
  """

  alias Wavex.Error.BlockAlignMismatch

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
    def to_string(%BlockAlignMismatch{expected: expected, actual: actual}) do
      "expected block align #{expected}, got: #{actual}"
    end
  end
end
