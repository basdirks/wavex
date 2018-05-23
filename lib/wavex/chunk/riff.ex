defmodule Wavex.Chunk.RIFF do
  @moduledoc """
  A RIFF (Resource Interchange File Format) chunk.
  """

  alias Wavex.Error.{
    UnexpectedEOF,
    UnexpectedFourCC
  }

  alias Wavex.FourCC

  @enforce_keys [:size]

  defstruct [:size]

  @type t :: %__MODULE__{size: pos_integer}

  @four_cc "RIFF"
  @four_cc_wave "WAVE"

  @spec four_cc :: FourCC.t()
  def four_cc, do: @four_cc

  @doc """
  Read a RIFF chunk.
  """
  @spec read(binary) ::
          {:ok, t, binary}
          | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
  def read(<<
        riff_id::binary-size(4),
        size::32-little,
        wave_id::binary-size(4),
        etc::binary
      >>) do
    with :ok <- FourCC.verify(riff_id, @four_cc),
         :ok <- FourCC.verify(wave_id, @four_cc_wave) do
      {:ok, %__MODULE__{size: size}, etc}
    end
  end

  def read(binary) when is_binary(binary), do: {:error, %UnexpectedEOF{}}
end
