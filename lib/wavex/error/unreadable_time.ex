defmodule Wavex.Error do
  defmodule UnreadableTime do
    @moduledoc ~S"""
    An unreadable time. Times have to be of the form "hh-mm-ss", where the
    minus/hyphen may be any character.
    """

    alias Wavex.Error.UnreadableTime

    @enforce_keys [:actual]

    defstruct [:actual]

    @type t :: %__MODULE__{actual: <<_::64>>}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(%UnreadableTime{actual: actual}) do
        "expected time to be of the form \"hh-mm-ss\", got: \"#{actual}\""
      end
    end
  end
end
