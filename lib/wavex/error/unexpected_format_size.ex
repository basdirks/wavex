defmodule Wavex.Error.UnexpectedFormatSize do
  @moduledoc """
  An unexpected format size. A format size of 16 is expected.
  """

  alias Wavex.Error.UnexpectedFormatSize

  @enforce_keys [:actual]

  defstruct [:actual]

  @type t :: %__MODULE__{actual: non_neg_integer}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%UnexpectedFormatSize{actual: actual}) do
      "expected format size 16, got: #{actual}"
    end
  end
end
