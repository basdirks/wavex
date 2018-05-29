defmodule Wavex.Error.UnexpectedEOF do
  @moduledoc """
  An unexpected end of file.
  """

  defstruct []

  @type t :: %__MODULE__{}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(_), do: "expected more data, got an end of file"
  end
end
