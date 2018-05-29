defmodule Wavex.Error.RIFFSizeMismatch do
  @moduledoc """
  A RIFF size that does not correspond to the file size. RIFF size must be
  equal to file size - 8.
  """

  alias Wavex.Error.RIFFSizeMismatch

  @enforce_keys [
    :expected,
    :actual
  ]

  defstruct [
    :expected,
    :actual
  ]

  @type t :: %__MODULE__{actual: non_neg_integer, expected: non_neg_integer}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%RIFFSizeMismatch{expected: expected, actual: actual}) do
      "expected RIFF size #{expected}, got: #{actual}"
    end
  end
end
