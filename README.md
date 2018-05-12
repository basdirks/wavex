# Wavex

[![Hex.pm](https://img.shields.io/hexpm/v/wavex.svg?style=flat-square)](https://hex.pm/packages/wavex)
[![Build Status](https://travis-ci.org/basdirks/wavex.svg?branch=master)](https://travis-ci.org/basdirks/wavex)

Read LPCM WAVE data.

This package is still in early beta.

## Roadmap

Eventually, Wavex will support reading and writing of any valid LPCM WAVE
file, as specified in _EBU - TECH 3285: Specification of the Broadcast Wave
Format (BWF), Version 2.0_, a copy of which can be found at
`priv/tech3285.pdf` in the source repository.

## Sources

* [EBU – TECH 3285: Specification of the Broadcast Wave Format (BWF), Version 2.0](https://tech.ebu.ch/docs/tech/tech3285.pdf)
* [McGill Engineering: Wave File Specifications](http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html)
* [Library of Congress: WAVE Audio File Format](https://www.loc.gov/preservation/digital/formats/fdd/fdd000001.shtml)

## Installation

1.  Add `wavex` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:wavex, "~> 0.7.1"}
  ]
end
```

2.  Update your dependencies:

```elixir
$ mix deps.get
```
