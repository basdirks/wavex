defmodule Wavex.Error.UnreadableDate do
  @moduledoc ~S"""
  An unreadable date. Dates have to be of the form "yyyy-mm-dd", where the
  minus/hyphen may be any character.
  """

  alias Wavex.Error.UnreadableDate

  @enforce_keys [:actual]

  defstruct [:actual]

  @type t :: %__MODULE__{actual: <<_::80>>}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%UnreadableDate{actual: actual}) do
      "expected date to be of the form \"yyyy-mm-dd\", got: \"#{actual}\""
    end
  end
end
