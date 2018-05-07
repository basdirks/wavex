defmodule WavexTest do
  use ExUnit.Case
  doctest Wavex
  doctest Wavex.DataChunk
  doctest Wavex.Error
  doctest Wavex.Error.BlockAlignMismatch
  doctest Wavex.Error.ByteRateMismatch
  doctest Wavex.Error.DataSizeMismatch
  doctest Wavex.Error.UnexpectedEOF
  doctest Wavex.Error.UnexpectedFormatSize
  doctest Wavex.Error.UnexpectedFourCC
  doctest Wavex.Error.UnsupportedBitsPerSample
  doctest Wavex.Error.UnsupportedFormat
  doctest Wavex.Error.ZeroChannels
  doctest Wavex.FormatChunk
  doctest Wavex.RIFFHeader
  doctest Wavex.Utils
end
