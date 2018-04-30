defmodule Wavex.RIFFHeader do
  @moduledoc false

  alias Wavex.Utils

  defstruct [:size]

  @type t :: %__MODULE__{}

  @doc ~S"""
  Read a RIFF header.

  ## Examples

      From [sapp.org, 2018-04-30, Microsoft WAVE soundfile format](http://soundfile.sapp.org/doc/WaveFormat/):

      iex> Wavex.RIFFHeader.read(<<0x52, 0x49, 0x46, 0x46, 0x24, 0x08, 0x00, 0x00, 0x57, 0x41, 0x56, 0x45>>)
      {:ok, %Wavex.RIFFHeader{size: 2084}, ""}

      iex> Wavex.RIFFHeader.read(<<"RIFX", 0, 0, 0, 0, "WAVE">>)
      {:error, "expected chunk id 'RIFF', got: 'RIFX'"}

      iex> Wavex.RIFFHeader.read(<<"RIFX", 0, 0, 0, 0, "WAVE">>)
      {:error, "expected chunk id 'RIFF', got: 'RIFX'"}

  """
  @spec read(binary) :: {:ok, t, binary} | {:error, binary}
  def read(binary) do
    with {:ok, etc} <- Utils.read_id(binary, "RIFF"),
         <<size::32-little, etc::binary>> <- etc,
         {:ok, etc} <- Utils.read_id(etc, "WAVE") do
      {:ok, %__MODULE__{size: size}, etc}
    else
      value when is_binary(value) -> {:error, "unexpected EOF"}
      error -> error
    end
  end
end