# Integration Guide

This guide describes how package authors can integrate their own packages
with the `IterableTables` ecosystem. Specifically, it explains how
one can turn a type into an iterable table and how one can write code
that consumes iterable tables.

# Overview

For now I recommend that all integrations with IterableTables should live
in the IterableTables package. This is a temporary solution until the
interface in IterableTables is more stable, at which point integrations
will be moved into the packages that they integrate. So new integrations
should at this point ideally be submitted as pull requests against the
[IterableTables repository](https://github.com/davidanthoff/IterableTables.jl).
Specifically, each integration should be put into a file in the folder
`src/integrations`, and the filename should be the name of the package
that is being integrated. The code in that file should live in a
`@require` block (see one of the existing integrations for an example).

# Consuming iterable tables

One cannot dispatch on an iterable table because iterable tables don't
have a common super type. Instead one has to add a method that takes any
type as an argument to consume an iterable table. For conversions between
types it is recommended that one adds a constructor that takes one argument
without any type restriction that can convert an iterable table into the
target type. For example, if one has added a new table type called `MyTable`,
one would add a constructor with this method signature for this type:
`function MyTable(iterable_table)`. For other situations, for example a
plotting function, one also would add a method without any type restriction,
for example `plot(iterable_table)`.

The first step inside any function that consumes iterable tables is to check
whether the argument that was passed is actually an iterable table or not.
This can easily be done with the `isiterabletable` function. For example,
the constructor for a new table type might start like this:
```julia
function MyTable(source)
    isiterabletable(source) || error("Argument is not an iterable table.")

    # Code that converts things follows
end
```
Once it has been established that the argument is actually an iterable
table there are multiple ways to proceed. The following two sections
describe two options, which one is appropriate for a given situation
depends on a variety of factors.

## Reusing an existing consumer of iterable tables

This option is by far the simplest way to add support for consuming an
iterable table. Essentially the strategy is to reuse the conversion
implementation of some other type. For example, one can simply convert
the iterable table into a `DataFrame` right after one has checked that
the argument of the function is actually an iterable table. Once the
iterable table is converted to a `DataFrame`, one can use the standard
API of `DataFrame`s to proceed. This strategy is especially simple for
packages that already support interaction with `DataFrames` (or any of
the other table types supported by IterableTables). The code for the
``MyTable`` constructor might look like this:
```julia
function MyTable(source)
    isiterabletable(source) || error("Argument is not an iterable table.")

    df = DataFrame(source)
    return MyTable(df)
end
```
This assumes that `MyTable` has another constructor that accepts a
`DataFrame`.

Currently the most efficient table type for this kind of conversion is
the `DataTable` type from the [DataTables.jl](https://github.com/JuliaData/DataTables.jl)
package. How efficient is this strategy in general? It really depends
what is happening in the next step with say the `DataTable` one constructed.
If the data will be copied into yet another data structure after it has
been converted to a `DataTable`, one has added at least one unnecessary
memory allocation in the conversion. For such a situation it is probably
more efficient to manually code a complete version, as described in the
next section. If, on the other hand, one for example requires a vector of
values for each column of the table, this approach can be quite efficient:
one can just access the vector in the `DataTable` and operate on that.

## Coding a complete conversion

[TODO]

# Creating an iterable table source

[TODO]
