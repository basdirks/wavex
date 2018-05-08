# Wavex

[![Hex.pm](https://img.shields.io/hexpm/v/wavex.svg?style=flat-square)](https://hex.pm/packages/wavex)

Read LPCM WAVE data.

This package is still in early beta. Eventually, Wavex will support reading and
writing of any valid LPCM WAVE file, as specified in EBU - TECH 3285:
Specification of the Broadcast Wave Format (BWF), Version 2.0, a copy of which
can be found at priv/tech3285.pdf of this repository.

Sources:

https://tech.ebu.ch/docs/tech/tech3285.pdf
http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html
https://www.loc.gov/preservation/digital/formats/fdd/fdd000001.shtml

## Installation

1.  Add `wavex` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:wavex, "~> 0.1.0"}
  ]
end
```

2.  Update your dependencies:

```elixir
$ mix deps.get
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/wavex](https://hexdocs.pm/wavex).
