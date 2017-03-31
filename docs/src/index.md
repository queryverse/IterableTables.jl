# Introduction

## Overview

IterableTables defines a  generic traits interface for tabular data.

The package currently has support for the following data sources:
[DataFrames](https://github.com/JuliaStats/DataFrames.jl),
[DataStreams](https://github.com/JuliaData/DataStreams.jl)
(including [CSV](https://github.com/JuliaData/CSV.jl),
[Feather](https://github.com/JuliaStats/Feather.jl),
[SQLite](https://github.com/JuliaDB/SQLite.jl),
[ODBC](https://github.com/JuliaDB/ODBC.jl)),
[DataTables](https://github.com/JuliaData/DataTables.jl),
[IndexedTables](https://github.com/JuliaComputing/IndexedTables.jl),
[TimeSeries](https://github.com/JuliaStats/TimeSeries.jl),
[TypedTables](https://github.com/FugroRoames/TypedTables.jl) and
any iterator who produces elements of type
[NamedTuple](https://github.com/blackrock/NamedTuples.jl).

The following data sinks are currently supported:
[DataFrames](https://github.com/JuliaStats/DataFrames.jl) (including things
like `ModelFrame` etc.),
[DataTables](https://github.com/JuliaData/DataTables.jl),
[TypedTables](https://github.com/FugroRoames/TypedTables.jl),
[StatsModels](https://github.com/JuliaStats/StatsModels.jl),
[Gadfly](https://github.com/GiovineItalia/Gadfly.jl) and
[VegaLite](https://github.com/fredo-dedup/VegaLite.jl).

## Installation

This package only works on julia 0.5 and newer. You can add it with:
```julia
Pkg.add("IterableTables")
```
