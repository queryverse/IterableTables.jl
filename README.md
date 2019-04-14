# IterableTables

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://queryverse.github.io/IterableTables.jl/stable)
[![Build Status](https://travis-ci.org/queryverse/IterableTables.jl.svg?branch=master)](https://travis-ci.org/queryverse/IterableTables.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/nf8lg1pef4xitjij/branch/master?svg=true)](https://ci.appveyor.com/project/queryverse/iterabletables-jl/branch/master)
[![Query](http://pkg.julialang.org/badges/IterableTables_0.5.svg)](http://pkg.julialang.org/?pkg=IterableTables)
[![Query](http://pkg.julialang.org/badges/IterableTables_0.6.svg)](http://pkg.julialang.org/?pkg=IterableTables)
[![codecov.io](http://codecov.io/github/queryverse/IterableTables.jl/coverage.svg?branch=master)](http://codecov.io/github/queryverse/IterableTables.jl?branch=master)

## Overview

Iterable tables is a  generic interface for tabular data.

A large number of packages are compatible with this interface. The following
packages can act as a source iterable table:

* [DataFrames](https://github.com/JuliaStats/DataFrames.jl)
* [DataTables](https://github.com/JuliaData/DataTables.jl)
* [Pandas](https://github.com/JuliaPy/Pandas.jl)
* [IndexedTables](https://github.com/JuliaComputing/IndexedTables.jl)
* [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl)
* [Temporal](https://github.com/dysonance/Temporal.jl)
* [TypedTables](https://github.com/FugroRoames/TypedTables.jl)
* [JuliaDB](https://github.com/JuliaComputing/JuliaDB.jl)
* [SQLite](https://github.com/JuliaDB/SQLite.jl)
* [ODBC](https://github.com/JuliaDB/ODBC.jl)
* [DifferentialEquations](https://github.com/JuliaDiffEq/DifferentialEquations.jl) (any ``DESolution``)
* [CSVFiles](https://github.com/queryverse/CSVFiles.jl)
* [ExcelFiles](https://github.com/queryverse/ExcelFiles.jl)
* [FeatherFiles](https://github.com/queryverse/FeatherFiles.jl)
* [ParquetFiles](https://github.com/queryverse/ParquetFiles.jl)
* [BedgraphFiles](https://github.com/CiaranOMara/BedgraphFiles.jl)
* [StatFiles](https://github.com/queryverse/StatFiles.jl)
* [CSV](https://github.com/JuliaData/CSV.jl)
* [Feather](https://github.com/JuliaStats/Feather.jl)
* [Query](https://github.com/queryverse/Query.jl)
* any iterator who produces elements of type [NamedTuple](https://github.com/blackrock/NamedTuples.jl)

The following data sinks are currently supported:
* [DataFrames](https://github.com/JuliaStats/DataFrames.jl)
* [DataTables](https://github.com/JuliaData/DataTables.jl)
* [Pandas](https://github.com/JuliaPy/Pandas.jl)
* [IndexedTables](https://github.com/JuliaComputing/IndexedTables.jl)
* [TimeSeries](https://github.com/JuliaStats/TimeSeries.jl)
* [Temporal](https://github.com/dysonance/Temporal.jl)
* [TypedTables](https://github.com/FugroRoames/TypedTables.jl)
* [JuliaDB](https://github.com/JuliaComputing/JuliaDB.jl)
* [StatsModels](https://github.com/JuliaStats/StatsModels.jl)
* [CSVFiles](https://github.com/queryverse/CSVFiles.jl)
* [FeatherFiles](https://github.com/queryverse/FeatherFiles.jl)
* [BedgraphFiles](https://github.com/CiaranOMara/BedgraphFiles.jl)
* [CSV](https://github.com/JuliaData/CSV.jl)
* [Feather](https://github.com/JuliaStats/Feather.jl)
* [StatPlots](https://github.com/JuliaPlots/StatPlots.jl)
* [Gadfly](https://github.com/GiovineItalia/Gadfly.jl)
* [VegaLite](https://github.com/fredo-dedup/VegaLite.jl)
* [TableView.jl](https://github.com/JuliaComputing/TableView.jl)
* [DataVoyager.jl](https://github.com/queryverse/DataVoyager.jl)
* [TableShowUtils.jl](https://github.com/queryverse/TableShowUtils.jl)
* [Query](https://github.com/queryverse/Query.jl)

The package is tightly integrated with [Query.jl](https://github.com/queryverse/Query.jl):
Any query that creates a named tuple in the last ``@select`` statement (and
doesn't ``@collect`` the results into a data structure) is automatically an
iterable table data source, and any of the data sources mentioned above can
be queried using [Query.jl](https://github.com/queryverse/Query.jl).

## Installation

This package only works on julia 0.5 and newer. You can add it with:
```julia
Pkg.add("IterableTables")
```

## Getting started

``IterableTables`` makes it easy to conver between different table types in julia. It also makes it possible to use any table type in situations where packages traditionally expected a ``DataFrame``.

For example, if you have a ``DataFrame``
````julia
using DataFrames

df = DataFrame(Name=["John", "Sally", "Jim"], Age=[34.,25.,67.], Children=[2,0,3], Income = [120_000, 20_000, 60_000])
````

you can easily convert this into any of the supported data sink types by simply constructing a new table type and passing your source ``df``:
````julia
using DataTables, TypedTables, IterableTables

# Convert to a DataTable
dt = DataTable(df)

# Convert to a TypedTable
tt = Table(df)

````
These conversions work in pretty much any direction. For example you can convert a ``TypedTable`` into a ``DataFrame``:
````julia
new_df = DataFrame(tt)
````
Or you can convert it to a ``DataTable``:
````julia
new_dt = DataTable(tt)
````
The general rule is that you can convert any sink into any source.

``IterableTables`` also adds methods to a number of packages that have traditionally only worked with ``DataFrame``s that make these packages work with any data source type defined in ``IterableTables``.

For example, you can run a regression on any of the source types:
````julia
using GLM, DataFrames

# Run a regression on a TypedTable
lm(@formula(Children~Age),tt)

# Run a regression on a DataTable
lm(@formula(Children~Age),dt)
````
Or you can plot any of these data sources with ``Gadfly``:
````julia
using Gadfly

# Plot a TypedTable
plot(tt, x=:Age, y=:Children, Geom.line)
````
Or with ``StatsPlots``:
````julia
using StatsPlots

# Plot a DataTable
@df dt plot(:Age, :Children)

@df dt scatter(:Age, :Children, markersize = sqrt.(:Income ./ 1000))
````
Again, this will work with any of the data sources listed above.
