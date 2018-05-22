defmodule Wavex.Chunk.BAE do
  @moduledoc """
  Read a Broadcast Audio Extension chunk.
  """

  alias Wavex.Error.{
    UnexpectedEOF,
    UnexpectedFourCC,
    UnreadableDate,
    UnreadableTime
  }

  alias Wavex.{
    FourCC,
    Utils
  }

  @enforce_keys [
    :size,
    :description,
    :originator,
    :originator_reference,
    :origination_date,
    :origination_time,
    :time_reference_low,
    :time_reference_high,
    :version,
    :umid,
    :loudness_value,
    :loudness_range,
    :max_true_peak_level,
    :max_momentary_loudness,
    :max_short_term_loudness
  ]

  defstruct [
    :size,
    :description,
    :originator,
    :originator_reference,
    :origination_date,
    :origination_time,
    :time_reference_low,
    :time_reference_high,
    :version,
    :umid,
    :loudness_value,
    :loudness_range,
    :max_true_peak_level,
    :max_momentary_loudness,
    :max_short_term_loudness
  ]

  @type t :: %__MODULE__{
          size: non_neg_integer,
          description: binary,
          originator: binary,
          originator_reference: binary,
          origination_date: Date.t(),
          origination_time: Time.t(),
          time_reference_low: non_neg_integer,
          time_reference_high: non_neg_integer,
          version: non_neg_integer,
          umid: <<_::512>>,
          loudness_value: integer,
          loudness_range: integer,
          max_true_peak_level: integer,
          max_momentary_loudness: integer,
          max_short_term_loudness: integer
        }

  @four_cc "bext"

  @spec four_cc :: FourCC.t()
  def four_cc, do: @four_cc

  @spec date(<<_::80>>) :: {:ok, Date.t()} | {:error, UnreadableDate.t()}
  defp date(
         <<
           year_binary::binary-size(4),
           _::8,
           month_binary::binary-size(2),
           _::8,
           day_binary::binary-size(2)
         >> = binary
       ) do
    with {year, ""} <- Integer.parse(year_binary),
         {month, ""} <- Integer.parse(month_binary),
         {day, ""} <- Integer.parse(day_binary) do
      Date.new(year, month, day)
    else
      _ -> {:error, %UnreadableDate{actual: binary}}
    end
  end

  @spec time(<<_::64>>) :: {:ok, Time.t()} | {:error, UnreadableTime.t()}
  defp time(
         <<
           hour_binary::binary-size(2),
           _::8,
           minute_binary::binary-size(2),
           _::8,
           second_binary::binary-size(2)
         >> = binary
       ) do
    with {hour, ""} <- Integer.parse(hour_binary),
         {minute, ""} <- Integer.parse(minute_binary),
         {second, ""} <- Integer.parse(second_binary) do
      Time.new(hour, minute, second)
    else
      _ -> {:error, %UnreadableTime{actual: binary}}
    end
  end

  @doc ~S"""
  Read a Broadcast Audio Extension chunk.
  """
  @spec read(binary) ::
          {:ok, t, binary}
          | {:error,
             UnexpectedEOF.t()
             | UnexpectedFourCC.t()
             | UnreadableDate.t()
             | UnreadableTime.t()}
  def read(<<
        bext_id::binary-size(4),
        size::32-little,
        description::binary-size(256),
        originator::binary-size(32),
        originator_reference::binary-size(32),
        date_binary::binary-size(10),
        time_binary::binary-size(8),
        time_reference_low::32-little,
        time_reference_high::32-little,
        version::16-little,
        umid::binary-size(64),
        loudness_value::16-signed-little,
        loudness_range::16-signed-little,
        max_true_peak_level::16-signed-little,
        max_momentary_loudness::16-signed-little,
        max_short_term_loudness::16-signed-little,
        etc::binary
      >>) do
    skip_bytes = size - 422

    with :ok <- FourCC.verify(bext_id, @four_cc),
         {:ok, date} <- date(date_binary),
         {:ok, time} <- time(time_binary),
         <<
           _::binary-size(skip_bytes),
           etc::binary
         >> <- etc do
      {:ok,
       %__MODULE__{
         size: size,
         description: Utils.take_until_null(description),
         originator: Utils.take_until_null(originator),
         originator_reference: Utils.take_until_null(originator_reference),
         origination_date: date,
         origination_time: time,
         time_reference_low: time_reference_low,
         time_reference_high: time_reference_high,
         version: version,
         umid: umid,
         loudness_value: loudness_value,
         loudness_range: loudness_range,
         max_true_peak_level: max_true_peak_level,
         max_momentary_loudness: max_momentary_loudness,
         max_short_term_loudness: max_short_term_loudness
       }, etc}
    else
      binary when is_binary(binary) -> {:error, binary, String.length(binary)}
    end
  end

  def read(binary) when is_binary(binary), do: {:error, %UnexpectedEOF{}}
end
