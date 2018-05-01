defmodule Wavex.RIFFHeader do
  @moduledoc """
  Read a RIFF header.
  """

  alias Wavex.Utils

  defstruct [:size]

  @type t :: %__MODULE__{size: pos_integer}

  @doc ~S"""
  Read a RIFF header.

  ## Examples

  From [sapp.org, 2018-04-30, Microsoft WAVE soundfile format](http://soundfile.sapp.org/doc/WaveFormat/):

      iex> Wavex.RIFFHeader.read(<<0x0052, 0x0049, 0x0046, 0x0046,
      ...>                         0x0024, 0x0008, 0x0000, 0x0000,
      ...>                         0x0057, 0x0041, 0x0056, 0x0045>>)
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
