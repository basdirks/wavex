defmodule Wavex.Error.UnsupportedBitrate do
  @moduledoc """
  An unsupported bits per sample value. Currently, only values of 8, 16,
  and 24 are supported.
  """

  alias Wavex.Error.UnsupportedBitrate

  @enforce_keys [:actual]

  defstruct [:actual]

  @type t :: %__MODULE__{actual: non_neg_integer}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%UnsupportedBitrate{actual: actual}) do
      "expected bits per sample to be 8, 16, or 24, got: #{actual}"
    end
  end
end
