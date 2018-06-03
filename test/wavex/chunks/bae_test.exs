defmodule Wavex.Chunk.BAETest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Wavex.Chunk.BAE

  @max_16_signed 2
                 |> :math.pow(15)
                 |> round()

  @max_16_unsigned 2
                   |> :math.pow(16)
                   |> round()

  @max_32_unsigned 2
                   |> :math.pow(32)
                   |> round()

  @range_16_signed -@max_16_signed..(@max_16_signed - 1)

  @range_16_unsigned 0..@max_16_unsigned

  @range_32_unsigned 0..@max_32_unsigned

  defp ascii_padded(max_length) do
    ExUnitProperties.gen all length <- StreamData.integer(0..max_length),
                             binary <- StreamData.string(:ascii, length: length) do
      binary <> String.duplicate(<<0>>, max_length - length)
    end
  end

  defp binary_padded(max_length) do
    ExUnitProperties.gen all length <- StreamData.integer(0..max_length),
                             binary <- StreamData.binary(length: length) do
      binary <> String.duplicate(<<0>>, max_length - length)
    end
  end

  defp zero_padded_integer(integer, count) do
    integer
    |> Integer.to_string()
    |> String.pad_leading(count, "0")
  end

  defp date_time_sep, do: StreamData.member_of([?-, ?_, ?:, ?\s, ?.])

  defp date_time do
    ExUnitProperties.gen all unix_time <- StreamData.integer(0..250_000_000_000),
                             sep1 <- date_time_sep(),
                             sep2 <- date_time_sep(),
                             sep3 <- date_time_sep(),
                             sep4 <- date_time_sep() do
      %DateTime{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second
      } = DateTime.from_unix!(unix_time)

      zero_padded_integer(year, 4) <>
        <<sep1>> <>
        zero_padded_integer(month, 2) <>
        <<sep2>> <>
        zero_padded_integer(day, 2) <>
        zero_padded_integer(hour, 2) <>
        <<sep3>> <> zero_padded_integer(minute, 2) <> <<sep4>> <> zero_padded_integer(second, 2)
    end
  end

  defp binary_v0 do
    ExUnitProperties.gen all description <- ascii_padded(256),
                             originator <- ascii_padded(32),
                             originator_reference <- ascii_padded(32),
                             origination_date_time <- date_time(),
                             time_reference_low <- StreamData.integer(@range_32_unsigned),
                             time_reference_high <- StreamData.integer(@range_32_unsigned),
                             coding_history <- StreamData.binary() do
      "bext" <>
        <<602 + byte_size(coding_history)::32-little>> <>
        description <>
        originator <>
        originator_reference <>
        origination_date_time <>
        <<
          time_reference_low::32-little,
          time_reference_high::32-little,
          0x0000::16-little,
          0x00::8*254
        >> <> coding_history
    end
  end

  defp binary_v1 do
    ExUnitProperties.gen all description <- ascii_padded(256),
                             originator <- ascii_padded(32),
                             originator_reference <- ascii_padded(32),
                             origination_date_time <- date_time(),
                             time_reference_low <- StreamData.integer(@range_32_unsigned),
                             time_reference_high <- StreamData.integer(@range_32_unsigned),
                             umid <- binary_padded(64),
                             coding_history <- StreamData.binary() do
      "bext" <>
        <<602 + byte_size(coding_history)::32-little>> <>
        description <>
        originator <>
        originator_reference <>
        origination_date_time <>
        <<
          time_reference_low::32-little,
          time_reference_high::32-little,
          0x0001::16-little
        >> <> umid <> <<0x00::8*190>> <> coding_history
    end
  end

  defp binary_v2 do
    ExUnitProperties.gen all description <- ascii_padded(256),
                             originator <- ascii_padded(32),
                             originator_reference <- ascii_padded(32),
                             origination_date_time <- date_time(),
                             time_reference_low <- StreamData.integer(@range_32_unsigned),
                             time_reference_high <- StreamData.integer(@range_32_unsigned),
                             umid <- binary_padded(64),
                             loudness_value <- StreamData.integer(@range_16_signed),
                             loudness_range <- StreamData.integer(@range_16_signed),
                             max_true_peak_level <- StreamData.integer(@range_16_signed),
                             max_momentary_loudness <- StreamData.integer(@range_16_signed),
                             max_short_term_loudness <- StreamData.integer(@range_16_signed),
                             coding_history <- StreamData.binary() do
      "bext" <>
        <<602 + byte_size(coding_history)::32-little>> <>
        description <>
        originator <>
        originator_reference <>
        origination_date_time <>
        <<
          time_reference_low::32-little,
          time_reference_high::32-little,
          0x0002::16-little
        >> <>
        umid <>
        <<
          loudness_value::16-signed-little,
          loudness_range::16-signed-little,
          max_true_peak_level::16-signed-little,
          max_momentary_loudness::16-signed-little,
          max_short_term_loudness::16-signed-little,
          0x00::8*180
        >> <> coding_history
    end
  end

  test "the associated FourCC" do
    assert BAE.four_cc() == "bext"
  end

  describe "reading a BAE chunk" do
    property "valid version 0" do
      check all binary <- binary_v0() do
        {:ok, chunk, ""} = BAE.read(binary)

        with %BAE{
               version: version,
               description: description,
               originator: originator,
               originator_reference: originator_reference,
               origination_time: origination_time,
               origination_date: origination_date,
               time_reference_low: time_reference_low,
               time_reference_high: time_reference_high,
               umid: umid,
               loudness_value: loudness_value,
               loudness_range: loudness_range,
               max_true_peak_level: max_true_peak_level,
               max_momentary_loudness: max_momentary_loudness,
               max_short_term_loudness: max_short_term_loudness
             } <- chunk do
          assert version == 0x0000
          assert is_binary(description)
          assert byte_size(description) in 0..256
          assert is_binary(originator)
          assert byte_size(originator) in 0..32
          assert is_binary(originator_reference)
          assert byte_size(originator_reference) in 0..32
          assert match?(%Date{}, origination_date)
          assert match?(%Time{}, origination_time)
          assert is_integer(time_reference_low)
          assert time_reference_low in @range_32_unsigned
          assert is_integer(time_reference_high)
          assert time_reference_high in @range_32_unsigned
          assert is_nil(umid)
          assert is_nil(loudness_value)
          assert is_nil(loudness_range)
          assert is_nil(max_true_peak_level)
          assert is_nil(max_momentary_loudness)
          assert is_nil(max_short_term_loudness)
        end
      end
    end

    property "valid version 1" do
      check all binary <- binary_v1() do
        {:ok, chunk, ""} = BAE.read(binary)

        with %BAE{
               version: version,
               description: description,
               originator: originator,
               originator_reference: originator_reference,
               origination_time: origination_time,
               origination_date: origination_date,
               time_reference_low: time_reference_low,
               time_reference_high: time_reference_high,
               umid: umid,
               loudness_value: loudness_value,
               loudness_range: loudness_range,
               max_true_peak_level: max_true_peak_level,
               max_momentary_loudness: max_momentary_loudness,
               max_short_term_loudness: max_short_term_loudness
             } <- chunk do
          assert version == 0x0001
          assert is_binary(description)
          assert byte_size(description) in 0..256
          assert is_binary(originator)
          assert byte_size(originator) in 0..32
          assert is_binary(originator_reference)
          assert byte_size(originator_reference) in 0..32
          assert match?(%Date{}, origination_date)
          assert match?(%Time{}, origination_time)
          assert is_integer(time_reference_low)
          assert time_reference_low in @range_32_unsigned
          assert is_integer(time_reference_high)
          assert time_reference_high in @range_32_unsigned
          assert is_binary(umid)
          assert byte_size(umid)
          assert is_nil(loudness_value)
          assert is_nil(loudness_range)
          assert is_nil(max_true_peak_level)
          assert is_nil(max_momentary_loudness)
          assert is_nil(max_short_term_loudness)
        end
      end
    end

    property "valid version 2" do
      check all binary <- binary_v2() do
        {:ok,
         %BAE{
           version: version,
           description: description,
           originator: originator,
           originator_reference: originator_reference,
           origination_time: origination_time,
           origination_date: origination_date,
           time_reference_low: time_reference_low,
           time_reference_high: time_reference_high,
           umid: umid,
           loudness_value: loudness_value,
           loudness_range: loudness_range,
           max_true_peak_level: max_true_peak_level,
           max_momentary_loudness: max_momentary_loudness,
           max_short_term_loudness: max_short_term_loudness
         }, ""} = BAE.read(binary)

        assert version == 0x0002
        assert is_binary(description)
        assert byte_size(description) in 0..256
        assert is_binary(originator)
        assert byte_size(originator) in 0..32
        assert is_binary(originator_reference)
        assert byte_size(originator_reference) in 0..32
        assert match?(%Date{}, origination_date)
        assert match?(%Time{}, origination_time)
        assert time_reference_low in @range_32_unsigned
        assert time_reference_high in @range_32_unsigned
        assert is_binary(umid)
        assert byte_size(umid)
        assert is_integer(loudness_value)
        assert loudness_value in @range_16_signed
        assert is_integer(loudness_range)
        assert loudness_range in @range_16_signed
        assert is_integer(max_true_peak_level)
        assert max_true_peak_level in @range_16_signed
        assert is_integer(max_momentary_loudness)
        assert max_momentary_loudness in @range_16_signed
        assert is_integer(max_short_term_loudness)
        assert max_short_term_loudness in @range_16_signed
      end
    end

    property "unknown version" do
      check all binary <- binary_v2(),
                version_unsupported <- StreamData.integer(@range_16_unsigned),
                not (version_unsupported in 0x0000..0x0002) do
        <<
          pre::binary-size(354),
          _::16-little,
          post::binary
        >> = binary

        binary = <<
          pre::binary,
          version_unsupported::16-little,
          post::binary
        >>

        {:error, {:unsupported_bae_version, actual}} = BAE.read(binary)

        assert actual == version_unsupported
      end
    end
  end
end
