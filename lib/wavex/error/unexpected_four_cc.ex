defmodule Wavex.Error.UnexpectedFourCC do
  @moduledoc ~S"""
  An unexpected four character code.
  """

  alias Wavex.Error.UnexpectedFourCC

  @enforce_keys [
    :expected,
    :actual
  ]

  defstruct [
    :expected,
    :actual
  ]

  @type t :: %__MODULE__{expected: <<_::32>>, actual: <<_::32>>}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%UnexpectedFourCC{expected: expected, actual: actual}) do
      "expected FourCC \"#{expected}\", got: \"#{actual}\""
    end
  end
end
