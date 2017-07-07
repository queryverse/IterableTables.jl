# User Guide

This guide describes how one can use `IterableTables` as a julia user.

## Overview

Any of the types that supports the iterable tables interface does so by loading the `IterableTables` package, nothing else needs to be done.

To convert things into a destination type one sometimes needs to obey some special conventions, depending on the destination type, but in general these conversions follow a simple pattern. The following sections describe how to convert and use an iterable table with various packages.

## DataFrames, DataTables, TypedTables

For all three packages one can simply pass an iterable table to a constructor call to construct a new instance of that type that holds a copy of the data that was stored in the iterable table. For example, assuming the data source is called `ds`, one can use the following code:

```julia
# Construct a DataFrame
df = DataFrame(ds)

# Construct a DataTable
dt = DataTable(ds)

# Construct a TypedTable
tt = Table(ds)
```

## TimeSeries

To construct a `TimeArray` instance, one needs a source that follows a number of rules: 1) it must have a column that is of type `TimeType` and 2) all other columns must be of one type. With such a source, one can use the following code to create a `TimeArray`, assuming that `ds` is an iterable table:

```julia
ta = TimeArray(ds, timestamp_column=:name_of_timestamp_column)
```

If the column with the timestamp information is named `timestamp` in the source, one can use a single argument constructor call:

```julia
ta = TimeArray(ds)
```

## Temporal

To construct a `TS` instance, one needs a source that follows a number of rules: 1) it must have a column that is of type `TimeType` and 2) all other columns must be of one type. With such a source, one can use the following code to create a `TS`, assuming that `ds` is an iterable table:

```julia
ta = TS(ds, timestamp_column=:name_of_timestamp_column)
```

If the column with the timestamp information is named `Index` in the source, one can use a single argument constructor call:

```julia
ta = TS(ds)
```


## IndexedTables

The simplest way to construct an `IndexedTable` is to call the one argument constructor on an iterable table `ds`:

```julia
it = IndexedTable(ds)
```

In this case the last column in the source will be the data column in the `IndexedTable`, and all other columns will be index columns.

One can manually select the index and data columns by using the keyword arguments `idxcols` and `datacols`. Both take a vector of `Symbol`s as arguments. For example, to make the `time` and `region` column in a data source the index columns, one would use the following command:

```julia
it = IndexedTable(ds, idxcols=[:time, :region])
```

In this case all remaining columns will be turned into data columns. If one only specifies the `datacols` argument, one will create an `IndexedTable` in which all columns that are not listed in the `datacols` argument will be turned into index columns. Finally, one can also specify both the `idxcols` and `datacols` argument at the same time (and thus even drop columns by noth listing them in either argument list).

## JuliaDB

The simplest way to load any iterable table `ds` into JuliaDB is to call the `distribute` function:

```julia
jdb = distribute(ds)
```

In addition to the arguments that `distribute` accepts in its normal JuliaDB definition, it also accepts named arguments `idxcols` and `datacols`, which have the same meaning as in the `InexedTable` case.

## DataStreams (CSV, Feather)

To write an iterable table into a CSV or Feather file is slightly more involved. In particular, one must call the function `IterableTables.get_datastreams_source` to create a `DataStream.Source` instance that can then be passed to either the `CSV.write` or `Feather.write` function.

To write an iterable table `ds` to a CSV file, one would therefor use the following code:

```julia
CSV.write("filename.csv", IterableTables.get_datastreams_source(ds))
```

And to write an iterable table to a Feather file, one would use the following code:

```julia
Feather.write("filename.csv", IterableTables.get_datastreams_source(ds))
```

## Gadfly and VegaLite

For both plotting packages one can simply pass an iterable table where one would normally have passed a `DataFrame`.

The following example plots an iterable table `ds` using Gadfly:

```julia
p = plot(ds, x=:a, y=:b, Geom.line)
```

And this code will plot an iterable table using VegaLite:

```julia
p = data_values(ds) +
    mark_line() +
    encoding_x_quant(:a) +
    encoding_y_quant(:b)
```

## StatsModels (and statistical models in DataFrames)

For statistical models one can use an iterable table instead of a `DataFrame`. Under the hood this is achieved by providing a constructor for `ModelFrame` that takes an iterable table, and by providing methods for the `fit` function that accept an iterable table instead of a `DataFrame`. For most users this implies that one can e.g. simply pass an iterable table to the `lm` and `glm` function in the GLM package (assuming `ds` is any iterable table):

```julia
OLS = glm(@formula(Y ~ X), ds, Normal(), IdentityLink())
```

## CSVFiles, FeatherFiles, ExcelFiles and StatFiles

See the README for [CSVFiles.jl](https://github.com/davidanthoff/CSVFiles.jl), [ExcelFiles.jl](https://github.com/davidanthoff/ExcelFiles.jl), [FeatherFiles.jl](https://github.com/davidanthoff/FeatherFiles.jl) and [StatFiles.jl](https://github.com/davidanthoff/StatFiles.jl) for documentation.
