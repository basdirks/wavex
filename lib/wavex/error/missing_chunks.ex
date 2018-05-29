defmodule Wavex.Error.MissingChunks do
  @moduledoc ~S"""
  Missing chunks.
  """

  alias Wavex.Error.MissingChunks

  @enforce_keys [:missing]

  defstruct [:missing]

  @type t :: %__MODULE__{missing: RIFF | Format | Data}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%MissingChunks{missing: missing}) do
      "missing chunks: \"#{inspect(missing)}\""
    end
  end
end
