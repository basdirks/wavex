defmodule Wavex.Error do
  @moduledoc """
  WAVE processing errors
  """

  alias __MODULE__.{
    BlockAlignMismatch,
    ByteRateMismatch,
    DataSizeMismatch,
    UnexpectedEOF,
    UnexpectedFormatSize,
    UnexpectedFourCC,
    UnsupportedBitsPerSample,
    UnsupportedFormat,
    ZeroChannels
  }

  @type t ::
          BlockAlignMismatch.t()
          | ByteRateMismatch.t()
          | DataSizeMismatch.t()
          | UnexpectedEOF.t()
          | UnexpectedFormatSize.t()
          | UnexpectedFourCC.t()
          | UnsupportedBitsPerSample.t()
          | UnsupportedFormat.t()
          | ZeroChannels.t()

  defmodule UnsupportedFormat do
    @moduledoc """
    An unsupported format. Currently, only 0x0001 (PCM) is supported.

        iex> to_string(%Wavex.Error.UnsupportedFormat{format: 0x0000})
        "expected format 1 (PCM), got: 0 (UNKNOWN)"

        iex> to_string(%Wavex.Error.UnsupportedFormat{format: 0x0050})
        "expected format 1 (PCM), got: 80 (MPEG)"

    """

    defstruct [:format]

    @type t :: %__MODULE__{format: non_neg_integer}

    defimpl String.Chars, for: __MODULE__ do
      # `@formats` were taken from github.com/tpn, 2018-05-01, winddk-8.1 / Include / shared / mmreg.h.
      # https://github.com/tpn/winddk-8.1/blob/master/Include/shared/mmreg.h

      @formats %{
        0x0000 => "UNKNOWN",
        0x0001 => "PCM",
        0x0002 => "ADPCM",
        0x0003 => "IEEE_FLOAT",
        0x0004 => "VSELP",
        0x0005 => "IBM_CVSD",
        0x0006 => "ALAW",
        0x0007 => "MULAW",
        0x0008 => "DTS",
        0x0009 => "DRM",
        0x000A => "WMAVOICE9",
        0x000B => "WMAVOICE10",
        0x0010 => "OKI_ADPCM",
        0x0011 => "IMA_ADPCM",
        0x0012 => "MEDIASPACE_ADPCM",
        0x0013 => "SIERRA_ADPCM",
        0x0014 => "G723_ADPCM",
        0x0015 => "DIGISTD",
        0x0016 => "DIGIFIX",
        0x0017 => "DIALOGIC_OKI_ADPCM",
        0x0018 => "MEDIAVISION_ADPCM",
        0x0019 => "CU_CODEC",
        0x001A => "HP_DYN_VOICE",
        0x0020 => "YAMAHA_ADPCM",
        0x0021 => "SONARC",
        0x0022 => "DSPGROUP_TRUESPEECH",
        0x0023 => "ECHOSC1",
        0x0024 => "AUDIOFILE_AF36",
        0x0025 => "APTX",
        0x0026 => "AUDIOFILE_AF10",
        0x0027 => "PROSODY_1612",
        0x0028 => "LRC",
        0x0030 => "DOLBY_AC2",
        0x0031 => "GSM610",
        0x0032 => "MSNAUDIO",
        0x0033 => "ANTEX_ADPCME",
        0x0034 => "CONTROL_RES_VQLPC",
        0x0035 => "DIGIREAL",
        0x0036 => "DIGIADPCM",
        0x0037 => "CONTROL_RES_CR10",
        0x0038 => "NMS_VBXADPCM",
        0x0039 => "CS_IMAADPCM",
        0x003A => "ECHOSC3",
        0x003B => "ROCKWELL_ADPCM",
        0x003C => "ROCKWELL_DIGITALK",
        0x003D => "XEBEC",
        0x0040 => "G721_ADPCM",
        0x0041 => "G728_CELP",
        0x0042 => "MSG723",
        0x0043 => "INTEL_G723_1",
        0x0044 => "INTEL_G729",
        0x0045 => "SHARP_G726",
        0x0050 => "MPEG",
        0x0052 => "RT24",
        0x0053 => "PAC",
        0x0055 => "MPEGLAYER3",
        0x0059 => "LUCENT_G723",
        0x0060 => "CIRRUS",
        0x0061 => "ESPCM",
        0x0062 => "VOXWARE",
        0x0063 => "CANOPUS_ATRAC",
        0x0064 => "G726_ADPCM",
        0x0065 => "G722_ADPCM",
        0x0066 => "DSAT",
        0x0067 => "DSAT_DISPLAY",
        0x0069 => "VOXWARE_BYTE_ALIGNED",
        0x0070 => "VOXWARE_AC8",
        0x0071 => "VOXWARE_AC10",
        0x0072 => "VOXWARE_AC16",
        0x0073 => "VOXWARE_AC20",
        0x0074 => "VOXWARE_RT24",
        0x0075 => "VOXWARE_RT29",
        0x0076 => "VOXWARE_RT29HW",
        0x0077 => "VOXWARE_VR12",
        0x0078 => "VOXWARE_VR18",
        0x0079 => "VOXWARE_TQ40",
        0x007A => "VOXWARE_SC3",
        0x007B => "VOXWARE_SC3_1",
        0x0080 => "SOFTSOUND",
        0x0081 => "VOXWARE_TQ60",
        0x0082 => "MSRT24",
        0x0083 => "G729A",
        0x0084 => "MVI_MVI2",
        0x0085 => "DF_G726",
        0x0086 => "DF_GSM610",
        0x0088 => "ISIAUDIO",
        0x0089 => "ONLIVE",
        0x008A => "MULTITUDE_FT_SX20",
        0x008B => "INFOCOM_ITS_G721_ADPCM",
        0x008C => "CONVEDIA_G729",
        0x008D => "CONGRUENCY",
        0x0091 => "SBC24",
        0x0092 => "DOLBY_AC3_SPDIF",
        0x0093 => "MEDIASONIC_G723",
        0x0094 => "PROSODY_8KBPS",
        0x0097 => "ZYXEL_ADPCM",
        0x0098 => "PHILIPS_LPCBB",
        0x0099 => "PACKED",
        0x00A0 => "MALDEN_PHONYTALK",
        0x00A1 => "RACAL_RECORDER_GSM",
        0x00A2 => "RACAL_RECORDER_G720_A",
        0x00A3 => "RACAL_RECORDER_G723_1",
        0x00A4 => "RACAL_RECORDER_TETRA_ACELP",
        0x00B0 => "NEC_AAC",
        0x00FF => "RAW_AAC1",
        0x0100 => "RHETOREX_ADPCM",
        0x0101 => "IRAT",
        0x0111 => "VIVO_G723",
        0x0112 => "VIVO_SIREN",
        0x0120 => "PHILIPS_CELP",
        0x0121 => "PHILIPS_GRUNDIG",
        0x0123 => "DIGITAL_G723",
        0x0125 => "SANYO_LD_ADPCM",
        0x0130 => "SIPROLAB_ACEPLNET",
        0x0131 => "SIPROLAB_ACELP4800",
        0x0132 => "SIPROLAB_ACELP8V3",
        0x0133 => "SIPROLAB_G729",
        0x0134 => "SIPROLAB_G729A",
        0x0135 => "SIPROLAB_KELVIN",
        0x0136 => "VOICEAGE_AMR",
        0x0140 => "G726ADPCM",
        0x0141 => "DICTAPHONE_CELP68",
        0x0142 => "DICTAPHONE_CELP54",
        0x0150 => "QUALCOMM_PUREVOICE",
        0x0151 => "QUALCOMM_HALFRATE",
        0x0155 => "TUBGSM",
        0x0160 => "MSAUDIO1",
        0x0161 => "WMAUDIO2",
        0x0162 => "WMAUDIO3",
        0x0163 => "WMAUDIO_LOSSLESS",
        0x0164 => "WMASPDIF",
        0x0170 => "UNISYS_NAP_ADPCM",
        0x0171 => "UNISYS_NAP_ULAW",
        0x0172 => "UNISYS_NAP_ALAW",
        0x0173 => "UNISYS_NAP_16K",
        0x0174 => "SYCOM_ACM_SYC008",
        0x0175 => "SYCOM_ACM_SYC701_G726L",
        0x0176 => "SYCOM_ACM_SYC701_CELP54",
        0x0177 => "SYCOM_ACM_SYC701_CELP68",
        0x0178 => "KNOWLEDGE_ADVENTURE_ADPCM",
        0x0180 => "FRAUNHOFER_IIS_MPEG2_AAC",
        0x0190 => "DTS_DS",
        0x0200 => "CREATIVE_ADPCM",
        0x0202 => "CREATIVE_FASTSPEECH8",
        0x0203 => "CREATIVE_FASTSPEECH10",
        0x0210 => "UHER_ADPCM",
        0x0215 => "ULEAD_DV_AUDIO",
        0x0216 => "ULEAD_DV_AUDIO_1",
        0x0220 => "QUARTERDECK",
        0x0230 => "ILINK_VC",
        0x0240 => "RAW_SPORT",
        0x0241 => "ESST_AC3",
        0x0249 => "GENERIC_PASSTHRU",
        0x0250 => "IPI_HS",
        0x0251 => "IPI_RPELP",
        0x0260 => "CS2",
        0x0270 => "SONY_SCX",
        0x0271 => "SONY_SCY",
        0x0272 => "SONY_ATRAC3",
        0x0273 => "SONY_SPC",
        0x0280 => "TELUM_AUDIO",
        0x0281 => "TELUM_IA_AUDIO",
        0x0285 => "NORCOM_VOICE_SYSTEMS_ADPCM",
        0x0300 => "FM_TOWNS_SND",
        0x0350 => "MICRONAS",
        0x0351 => "MICRONAS_CELP833",
        0x0400 => "BTV_DIGITAL",
        0x0401 => "INTEL_MUSIC_CODER",
        0x0402 => "INDEO_AUDIO",
        0x0450 => "QDESIGN_MUSIC",
        0x0500 => "ON2_VP7_AUDIO",
        0x0501 => "ON2_VP6_AUDIO",
        0x0680 => "VME_VMPCM",
        0x0681 => "TPC",
        0x08AE => "LIGHTWAVE_LOSSLESS",
        0x1000 => "OLIGSM",
        0x1001 => "OLIADPCM",
        0x1002 => "OLICELP",
        0x1003 => "OLISBC",
        0x1004 => "OLIOPR",
        0x1100 => "LH_CODEC",
        0x1101 => "LH_CODEC_CELP",
        0x1102 => "LH_CODEC_SBC8",
        0x1103 => "LH_CODEC_SBC12",
        0x1104 => "LH_CODEC_SBC16",
        0x1400 => "NORRIS",
        0x1401 => "ISIAUDIO_2",
        0x1500 => "SOUNDSPACE_MUSICOMPRESS",
        0x1600 => "MPEG_ADTS_AAC",
        0x1601 => "MPEG_RAW_AAC",
        0x1602 => "MPEG_LOAS",
        0x1608 => "NOKIA_MPEG_ADTS_AAC",
        0x1609 => "NOKIA_MPEG_RAW_AAC",
        0x160A => "VODAFONE_MPEG_ADTS_AAC",
        0x160B => "VODAFONE_MPEG_RAW_AAC",
        0x1610 => "MPEG_HEAAC",
        0x181C => "VOXWARE_RT24_SPEECH",
        0x1971 => "SONICFOUNDRY_LOSSLESS",
        0x1979 => "INNINGS_TELECOM_ADPCM",
        0x1C07 => "LUCENT_SX8300P",
        0x1C0C => "LUCENT_SX5363S",
        0x1F03 => "CUSEEME",
        0x1FC4 => "NTCSOFT_ALF2CM_ACM",
        0x2000 => "DVM",
        0x2001 => "DTS2",
        0x3313 => "MAKEAVI",
        0x4143 => "DIVIO_MPEG4_AAC",
        0x4201 => "NOKIA_ADAPTIVE_MULTIRATE",
        0x4243 => "DIVIO_G726",
        0x434C => "LEAD_SPEECH",
        0x564C => "LEAD_VORBIS",
        0x5756 => "WAVPACK_AUDIO",
        0x674F => "OGG_VORBIS_MODE_1",
        0x6750 => "OGG_VORBIS_MODE_2",
        0x6751 => "OGG_VORBIS_MODE_3",
        0x676F => "OGG_VORBIS_MODE_1_PLUS",
        0x6770 => "OGG_VORBIS_MODE_2_PLUS",
        0x6771 => "OGG_VORBIS_MODE_3_PLUS",
        0x7000 => "3COM_NBX",
        0x706D => "FAAD_AAC",
        0x7361 => "AMR_NB",
        0x7362 => "AMR_WB",
        0x7363 => "AMR_WP",
        0x7A21 => "GSM_AMR_CBR",
        0x7A22 => "GSM_AMR_VBR_SID",
        0xA100 => "COMVERSE_INFOSYS_G723_1",
        0xA101 => "COMVERSE_INFOSYS_AVQSBC",
        0xA102 => "COMVERSE_INFOSYS_SBC",
        0xA103 => "SYMBOL_G729_A",
        0xA104 => "VOICEAGE_AMR_WB",
        0xA105 => "INGENIENT_G726",
        0xA106 => "MPEG4_AAC",
        0xA107 => "ENCORE_G726",
        0xA108 => "ZOLL_ASAO",
        0xA109 => "SPEEX_VOICE",
        0xA10A => "VIANIX_MASC",
        0xA10B => "WM9_SPECTRUM_ANALYZER",
        0xA10C => "WMF_SPECTRUM_ANAYZER",
        0xA10D => "GSM_610",
        0xA10E => "GSM_620",
        0xA10F => "GSM_660",
        0xA110 => "GSM_69",
        0xA111 => "GSM_ADAPTIVE_MULTIRATE_WB",
        0xA112 => "POLYCOM_G72",
        0xA113 => "POLYCOM_G728",
        0xA114 => "POLYCOM_G729_A",
        0xA115 => "POLYCOM_SIREN",
        0xA116 => "GLOBAL_IP_ILBC",
        0xA117 => "RADIOTIME_TIME_SHIFT_RADIO",
        0xA118 => "NICE_ACA",
        0xA119 => "NICE_ADPCM",
        0xA11A => "VOCORD_G721",
        0xA11B => "VOCORD_G726",
        0xA11C => "VOCORD_G722_1",
        0xA11D => "VOCORD_G728",
        0xA11E => "VOCORD_G729",
        0xA11F => "VOCORD_G729_A",
        0xA120 => "VOCORD_G723_1",
        0xA121 => "VOCORD_LBC",
        0xA122 => "NICE_G728",
        0xA123 => "FRACE_TELECOM_G729",
        0xA124 => "CODIAN",
        0xF1AC => "FLAC"
      }

      def to_string(%UnsupportedFormat{format: format}) do
        "expected format 1 (PCM), got: #{format} (#{Map.get(@formats, format)})"
      end
    end
  end

  defmodule UnexpectedFormatSize do
    @moduledoc """
    An unexpected format size. A format size of 16 is expected.

        iex> to_string(%Wavex.Error.UnexpectedFormatSize{size: 18})
        "expected format size 16, got: 18"

    """

    defstruct [:size]

    @type t :: %__MODULE__{size: non_neg_integer}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(%UnexpectedFormatSize{size: size}) do
        "expected format size 16, got: #{size}"
      end
    end
  end

  defmodule UnsupportedBitsPerSample do
    @moduledoc """
    An unsupported bits per sample value. Currently, only values of 8, 16,
    and 24 are supported.

        iex> to_string(%Wavex.Error.UnsupportedBitsPerSample{bits_per_sample: 32})
        "expected bits per sample to be 8, 16, or 24, got: 32"

    """

    defstruct [:bits_per_sample]

    @type t :: %__MODULE__{bits_per_sample: non_neg_integer}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(%UnsupportedBitsPerSample{bits_per_sample: bits_per_sample}) do
        "expected bits per sample to be 8, 16, or 24, got: #{bits_per_sample}"
      end
    end
  end

  defmodule ZeroChannels do
    @moduledoc """
    A channel value of 0. The number of channels must be positive.

        iex> to_string(%Wavex.Error.ZeroChannels{})
        "expected a positive number of channels"

    """

    defstruct []

    @type t :: %__MODULE__{}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(_), do: "expected a positive number of channels"
    end
  end

  defmodule UnexpectedEOF do
    @moduledoc """
    An unexpected end of file.

        iex> to_string(%Wavex.Error.UnexpectedEOF{})
        "expected more data, got an end of file"

    """

    defstruct []

    @type t :: %__MODULE__{}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(_), do: "expected more data, got an end of file"
    end
  end

  defmodule BlockAlignMismatch do
    @moduledoc """
    A mismatched block align value.

        iex> to_string(%Wavex.Error.BlockAlignMismatch{expected: 1, actual: 2})
        "expected block align 1, got: 2"

    """

    defstruct [:expected, :actual]

    @type t :: %__MODULE__{expected: non_neg_integer, actual: non_neg_integer}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(%BlockAlignMismatch{expected: expected, actual: actual}) do
        "expected block align #{expected}, got: #{actual}"
      end
    end
  end

  defmodule ByteRateMismatch do
    @moduledoc """
    A mismatched byte rate value.

        iex> to_string(%Wavex.Error.ByteRateMismatch{expected: 44_100, actual: 88_200})
        "expected byte rate 44100, got: 88200"

    """

    defstruct [:expected, :actual]

    @type t :: %__MODULE__{expected: non_neg_integer, actual: non_neg_integer}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(%ByteRateMismatch{expected: expected, actual: actual}) do
        "expected byte rate #{expected}, got: #{actual}"
      end
    end
  end

  defmodule UnexpectedFourCC do
    @moduledoc ~S"""
    An unexpected four character code.

        iex> to_string(%Wavex.Error.UnexpectedFourCC{expected: "WAVE", actual: "DIVX"})
        "expected FourCC \"WAVE\", got: \"DIVX\""

    """

    defstruct [:expected, :actual]

    @type t :: %__MODULE__{expected: binary, actual: binary}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(%UnexpectedFourCC{expected: expected, actual: actual}) do
        "expected FourCC \"#{expected}\", got: \"#{actual}\""
      end
    end
  end

  defmodule DataSizeMismatch do
    @moduledoc ~S"""
    An unexpected data size.

        iex> to_string(%Wavex.Error.DataSizeMismatch{expected: 52, actual: 50})
        "expected data size 52, got: 50"

    """

    defstruct [:expected, :actual]

    @type t :: %__MODULE__{expected: binary, actual: binary}

    defimpl String.Chars, for: __MODULE__ do
      def to_string(%DataSizeMismatch{expected: expected, actual: actual}) do
        "expected data size #{expected}, got: #{actual}"
      end
    end
  end
end
