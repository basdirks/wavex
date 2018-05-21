defmodule Wavex.Chunk.RIFF do
  @moduledoc """
  Read a RIFF chunk.
  """

  alias Wavex.Error.{UnexpectedEOF, UnexpectedFourCC}
  alias Wavex.Utils

  @enforce_keys [:size]

  defstruct [:size]

  @type t :: %__MODULE__{size: pos_integer}

  @spec read(binary) ::
          {:ok, t, binary}
          | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(<<
        riff_id::binary-size(4),
        size::32-little,
        wave_id::binary-size(4),
        etc::binary
      >>) do
    with :ok <- Utils.verify_four_cc(riff_id, "RIFF"),
         :ok <- Utils.verify_four_cc(wave_id, "WAVE") do
      {:ok, %__MODULE__{size: size}, etc}
    end
  end

  def read(binary) when is_binary(binary), do: {:error, %UnexpectedEOF{}}
end
