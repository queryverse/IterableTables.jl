# IterableTables

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://github.com/queryverse/IterableTables.jl/actions/workflows/juliaci.yml/badge.svg?branch=main)](https://github.com/queryverse/IterableTables.jl/actions/workflows/juliaci.yml)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://queryverse.github.io/IterableTables.jl/stable)
[![codecov.io](http://codecov.io/github/queryverse/IterableTables.jl/coverage.svg?branch=main)](http://codecov.io/github/queryverse/IterableTables.jl?branch=main)

## Overview

Iterable tables is a generic interface for tabular data, defined in
[TableTraits.jl](https://github.com/queryverse/TableTraits.jl).

This package historically hosted the interface implementations for many
third-party table types. That role is over: packages like
[DataFrames](https://github.com/JuliaData/DataFrames.jl),
[TimeSeries](https://github.com/JuliaStats/TimeSeries.jl) and
[StatsModels](https://github.com/JuliaStats/StatsModels.jl) have long
implemented the iterable tables interface natively (typically via
[Tables.jl](https://github.com/JuliaData/Tables.jl)), so they interoperate
with the [Queryverse](https://github.com/queryverse) without any help from
this package.

What this package still provides:

* Any iterator of `NamedTuple`s — for example a generator expression such as
  `((a=i, b=i^2) for i in 1:10)` — becomes an iterable table, so it can be
  queried with [Query.jl](https://github.com/queryverse/Query.jl) or passed
  to any iterable table sink.
* An integration for [Temporal](https://github.com/JTAmos/Temporal.jl),
  which has no native support for the interface: a `TS` value works as a
  source, and `TS(iterable_table; index_column=:Index)` works as a sink.

## Installation

```julia
julia> ]add IterableTables
```

## Getting started

A generator of named tuples can be piped into a query or into any sink, for
example a `DataFrame` or a CSV file:

```julia
using IterableTables, Query, DataFrames, CSVFiles, FileIO

g = ((a=i, b=i^2) for i in 1:10)

df = g |> @filter(_.a > 5) |> DataFrame

save("data.csv", g)
```

A `Temporal.TS` works as a source and sink around a query:

```julia
using IterableTables, Query, Temporal

ts2 = ts |> @filter(_.price > 100.) |> x -> TS(x, index_column=:Index)
```

For sinks that only accept concrete table types (for example
`Gadfly.plot` or the `TimeArray` constructor from
[TimeSeries](https://github.com/JuliaStats/TimeSeries.jl)), convert the
query result to a `DataFrame` first:

```julia
using Gadfly

df |> @filter(_.a > 5) |> DataFrame |> d -> plot(d, x=:a, y=:b, Geom.point)
```

## Historical note

Earlier versions of this package shipped `@require`-based integrations for
DataFrames, TimeSeries, StatsModels, Gadfly and JuliaDB. These were removed:
the first three gained native support for the interface years ago (the
integrations here had already been dead code since 2019), and the Gadfly and
JuliaDB integrations had been disabled since 2018. New integrations should be
implemented in the package that defines the table type, using
[TableTraits.jl](https://github.com/queryverse/TableTraits.jl) — see the
[documentation](https://queryverse.github.io/IterableTables.jl/stable) for an
integration guide.
