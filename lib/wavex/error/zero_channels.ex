defmodule Wavex.Error.ZeroChannels do
  @moduledoc """
  A channel value of 0. The number of channels must be positive.
  """

  defstruct []

  @type t :: %__MODULE__{}

  defimpl String.Chars, for: __MODULE__ do
    def to_string(_), do: "expected a positive number of channels"
  end
end
