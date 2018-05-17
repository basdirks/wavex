defmodule Wavex.Chunk.BAE do
  @moduledoc """
  Read a Broadcast Audio Extension chunk.
  """

  alias Wavex.Utils

  alias Wavex.Error.{
    UnexpectedEOF,
    UnexpectedFourCC,
    UnreadableDate,
    UnreadableTime
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

  # Comments from EBU - TECH 3285: Specification of the Broadcast Wave Format
  # (BWF), Version 2.0.
  defstruct [
    :size,

    # ASCII string (maximum 256 characters) containing a free description of
    # the sequence. To help applications which display only a short
    # description, it is recommended that a resume of the description is
    # contained in the first 64 characters and the last 192 characters are used
    # for details.

    # If the length of the string is less than 256 characters the last one
    # shall be followed by a null character (00).
    :description,

    # ASCII string (maximum 32 characters) containing the name of the
    # originator/ producer of the audio file. If the length of the string is
    # less than 32 characters the field shall be ended by a null character.
    :originator,

    # ASCII string (maximum 32 characters) containing an unambiguous
    # reference allocated by the originating organisation. If the length of the
    # string is less than 32 characters the field shall be terminated by a null
    # character.
    :originator_reference,

    # 10 ASCII characters containing the date of creation of the audio
    # sequence. The format shall be « ‘,year’,-,’month,’-‘,day,’»
    # with 4 characters for the year and 2 characters per other item.

    # Year is defined from 0000 to 9999
    # Month is defined from 1 to 12
    # Day is defined from 1 to 28, 29, 30 or 31

    # The separator between the items can be anything but it is recommended
    # that one of the following characters be used:

    # ‘-’ hyphen
    # ‘_’ underscore
    # ‘:’ colon
    # ‘ ’ space
    # ‘.’ stop
    :origination_date,

    # 8 ASCII characters containing the time of creation of the audio sequence.
    # The format shall be « ‘hour’-‘minute’-‘second’» with 2 characters per
    # item.

    # Hour is defined from 0 to 23.
    # Minute and second are defined from 0 to 59.

    # The separator between the items can be anything but it is recommended
    # that one of the following characters be used:

    # ‘-’ hyphen
    # ‘_’ underscore
    # ‘:’ colon
    # ‘ ’ space
    # ‘.’ stop
    :origination_time,

    # These fields shall contain the time-code of the sequence. It is a 64-bit
    # value which contains the first sample count since midnight. The number
    # of samples per second depends on the sample frequency which is defined
    # in the field <nSamplesPerSec> from the <format chunk>.
    :time_reference_low,
    :time_reference_high,

    # An unsigned binary number giving the version of the BWF. This number is
    # particularly relevant for the carriage of the UMID and loudness
    # information. For Version 1 it shall be set to 0001h and for Version 2 it
    # shall be set to 0002h.
    :version,

    # 64 bytes containing a UMID (Unique Material Identifier) to standard
    # SMPTE 330M [1]. If only a 32 byte "basic UMID" is used, the last 32 bytes
    # should be set to zero. (The length of the UMID is given internally.)
    :umid,

    # A 16-bit signed integer, equal to round(100x the Integrated Loudness
    # Value of the file in LUFS).
    :loudness_value,

    # A 16-bit signed integer, equal to round(100x the Loudness Range of the
    # file in LU).
    :loudness_range,

    # A 16-bit signed integer, equal to round(100x the Maximum True Peak
    # Value of the file in dBTP).
    :max_true_peak_level,

    # A 16-bit signed integer, equal to round(100x the highest value of the
    # Momentary Loudness Level of the file in LUFS).
    :max_momentary_loudness,

    # A 16-bit signed integer, equal to round(100x the highest value of the
    # Short-term Loudness Level of the file in LUFS).
    :max_short_term_loudness

    # Unrestricted ASCII characters containing a collection of strings
    # terminated by CR/LF. Each string shall contain a description of a coding
    # process applied to the audio data. Each new coding application shall add
    # a new string with the appropriate information.

    # This information shall contain the type of sound (PCM or MPEG) with its
    # specific parameters:

    # PCM: mode (mono, stereo), size of the sample (8, 16 bits) and sample
    # frequency,

    # MPEG: sample frequency, bit rate, layer (I or II) and the mode (mono,
    # stereo, joint stereo or dual channel),

    # It is recommended that the manufacturers of the coders provide an ASCII
    # string for use in the coding history.
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

  ## Examples

      iex> binary = <<
      ...>   0x62, 0x65, 0x78, 0x74,
      ...>   0x5C, 0x02, 0x00, 0x00,
      ...>   0x53, 0x69, 0x6E, 0x65,
      ...>   0x20, 0x57, 0x61, 0x76,
      ...>   0x65, 0x20, 0x46, 0x69,
      ...>   0x6C, 0x65, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x54, 0x6F, 0x6E, 0x65,
      ...>   0x73, 0x2E, 0x65, 0x78,
      ...>   0x65, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x32, 0x30, 0x31, 0x37,
      ...>   0x2D, 0x30, 0x36, 0x2D,
      ...>   0x30, 0x33, 0x31, 0x33,
      ...>   0x3A, 0x34, 0x32, 0x3A,
      ...>   0x31, 0x30, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x02, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00,
      ...>   0x00, 0x00, 0x00, 0x00
      ...> >>
      iex> wave = Wavex.Chunk.BAE.read(binary)
      iex> match?(
      ...>   {:ok,
      ...>    %Wavex.Chunk.BAE{
      ...>      description: "Sine Wave File",
      ...>      loudness_range: 0,
      ...>      loudness_value: 0,
      ...>      max_momentary_loudness: 0,
      ...>      max_short_term_loudness: 0,
      ...>      max_true_peak_level: 0,
      ...>      origination_date: ~D[2017-06-03],
      ...>      origination_time: ~T[13:42:10],
      ...>      originator: "Tones.exe",
      ...>      originator_reference: "",
      ...>      size: 604,
      ...>      time_reference_high: 0,
      ...>      time_reference_low: 0,
      ...>      umid: _,
      ...>      version: 0
      ...>    }, ""},
      ...>   wave
      ...> )
      true

  """
  @spec read(binary) :: {:ok, t, binary} | {:error, UnexpectedEOF.t() | UnexpectedFourCC.t()}
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

    with :ok <- Utils.verify_four_cc(bext_id, "bext"),
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
