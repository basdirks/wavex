defmodule Wavex.Chunk.BAE do
  @moduledoc """
  A BAE (Broadcast Audio Extension) chunk.
  """

  alias Wavex.{
    FourCC,
    CString
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
    :version
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
          umid: <<_::512>> | nil,
          loudness_value: integer | nil,
          loudness_range: integer | nil,
          max_true_peak_level: integer | nil,
          max_momentary_loudness: integer | nil,
          max_short_term_loudness: integer | nil
        }

  @type date_binary :: <<_::80>>

  @type time_binary :: <<_::64>>

  @four_cc "bext"

  @doc """
  The ID that identifies a BAE chunk.
  """
  @spec four_cc :: FourCC.t()
  def four_cc, do: @four_cc

  @spec date(date_binary) :: {:ok, Date.t()} | {:error, :unreadable_date, date_binary}
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
      _ -> {:error, {:unreadable_date, binary}}
    end
  end

  @spec time(time_binary) :: {:ok, Time.t()} | {:error, :unreadable_time, time_binary}
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
      _ -> {:error, {:unreadable_time, %{actual: binary}}}
    end
  end

  defp read_v0(%__MODULE__{size: size} = chunk, etc) do
    skip_bytes = size - 348

    with <<
           _::binary-size(skip_bytes),
           etc::binary
         >> <- etc do
      {:ok, chunk, etc}
    else
      binary when is_binary(binary) -> {:error, :unexpected_eof}
    end
  end

  defp read_v1(%__MODULE__{size: size} = chunk, etc) do
    skip_bytes = size - 412

    with <<
           # 356 - 419
           umid::binary-size(64),
           # 420 - ...
           _::binary-size(skip_bytes),
           etc::binary
         >> <- etc do
      {:ok, %__MODULE__{chunk | umid: umid}, etc}
    else
      binary when is_binary(binary) -> {:error, :unexpected_eof}
    end
  end

  defp read_v2(%__MODULE__{size: size} = chunk, etc) do
    skip_bytes = size - 422

    with <<
           # 356 - 419
           umid::binary-size(64),
           # 420 - 421
           loudness_value::16-signed-little,
           # 422 - 423
           loudness_range::16-signed-little,
           # 424 - 425
           max_true_peak_level::16-signed-little,
           # 426 - 427
           max_momentary_loudness::16-signed-little,
           # 428 - 429
           max_short_term_loudness::16-signed-little,
           # 430 - ...
           _::binary-size(skip_bytes),
           etc::binary
         >> <- etc do
      {:ok,
       %__MODULE__{
         chunk
         | umid: umid,
           loudness_value: loudness_value,
           loudness_range: loudness_range,
           max_true_peak_level: max_true_peak_level,
           max_momentary_loudness: max_momentary_loudness,
           max_short_term_loudness: max_short_term_loudness
       }, etc}
    else
      binary when is_binary(binary) -> {:error, :unexpected_eof}
    end
  end

  @doc ~S"""
  Read a BAE chunk.
  """
  @spec read(binary) ::
          {:ok, t, binary}
          | {:error,
             :unexpected_eof
             | {:unexpected_four_cc, %{actual: FourCC.t(), expected: FourCC.t()}}
             | {:unreadable_date, date_binary}
             | {:unreadable_time, time_binary}
             | {:unsupported_bae_version, non_neg_integer}}
  def read(binary) do
    with <<
           # 0 - 3
           bext_id::binary-size(4),
           # 4 - 7
           size::32-little,
           # 8 - 263
           description::binary-size(256),
           # 264 - 295
           originator::binary-size(32),
           # 296 - 327
           originator_reference::binary-size(32),
           # 328 - 337
           date_binary::binary-size(10),
           # 338 - 345
           time_binary::binary-size(8),
           # 346 - 349
           time_reference_low::32-little,
           # 350 - 353
           time_reference_high::32-little,
           # 354 - 355
           version::16-little,
           etc::binary
         >> <- binary,
         :ok <- FourCC.verify(bext_id, @four_cc),
         {:ok, date} <- date(date_binary),
         {:ok, time} <- time(time_binary),
         chunk <- %__MODULE__{
           size: size,
           description: CString.read(description),
           originator: CString.read(originator),
           originator_reference: CString.read(originator_reference),
           origination_date: date,
           origination_time: time,
           time_reference_low: time_reference_low,
           time_reference_high: time_reference_high,
           version: version
         },
         {:ok, _, _} = result <-
           (case version do
              0x00 -> read_v0(chunk, etc)
              0x01 -> read_v1(chunk, etc)
              0x02 -> read_v2(chunk, etc)
              _ -> {:error, {:unsupported_bae_version, version}}
            end) do
      result
    else
      binary when is_binary(binary) -> {:error, :unexpected_eof}
      error -> error
    end
  end
end
