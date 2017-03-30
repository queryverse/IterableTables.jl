# IterableTables

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://davidanthoff.github.io/IterableTables.jl/stable)
[![Build Status](https://travis-ci.org/davidanthoff/IterableTables.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/IterableTables.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/uv9ybxa17e8581pr/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/iterabletables-jl/branch/master)
[![Query](http://pkg.julialang.org/badges/IterableTables_0.5.svg)](http://pkg.julialang.org/?pkg=IterableTables)
[![codecov.io](http://codecov.io/github/davidanthoff/IterableTables.jl/coverage.svg?branch=master)](http://codecov.io/github/davidanthoff/IterableTables.jl?branch=master)

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
like ``ModelFrame`` etc.),
[DataTables](https://github.com/JuliaData/DataTables.jl),
[TypedTables](https://github.com/FugroRoames/TypedTables.jl),
[StatsModels](https://github.com/JuliaStats/StatsModels.jl),
[Gadfly](https://github.com/GiovineItalia/Gadfly.jl) and
[VegaLite](https://github.com/fredo-dedup/VegaLite.jl).
