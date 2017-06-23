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

Coding a custom conversion is more work than reusing an existing consumer
of iterable tables, but it provides more flexibility.

In general, a custom
conversion function also needs to start with a call to `isiterable` to
check whether one actually has an iterable table. The second step in any
custom conversion function is to all the `getiterator` function on the
iterable table. This will return an instance of a type that implements
the standard julia iterator interface, i.e. one can call `start`, `next`
and `done` on the instance that is returned by `getiterator`. For some
iterable tables `getiterator` will just return the argument that one has
passed to it, but for other iterable tables it will return an instance
of a different type.

`getiterator` is generally not a type stable function. Given that this
function is generally only called once per conversion this hopefully
is not a huge performance issue. The functions that really need to be
type-stable are `start`, `next` and `done` because they will be called
for every row of the table that is to be converted. In general, these three
functions will be type stable for the type of the return value of
`getiterator`. But given that `getiterator` is not type stable, one needs
to use a function barrier to make sure the three iteration functions are
called from a type stable function.

The next step in a custom conversion function is typically to find out
what columns the iterable table has. The helper functions
`IterableTables.column_types` and `IterableTables.column_names` provide
this functionality (note that these are not part of the official iterable
tables interface, they are simply helper functions that make it easier to
find this information). Both functions need to be called with the return
value of `getiterator` as the argument. `IterableTables.column_types`
returns a vector of `Type`s that are the element types of the columns of
the iterable table. `IterableTables.column_names` returns a vector of
`Symbol`s with the names of the columns.

Custom conversion functions can at this point optionally check whether
the iterable table implements the `length` function by checking whether
`Base.iteratorsize(typeof(iter))==Base.HasLength()` (this is part of the
standard iteration protocol). It is important to note that every consumer
of iterable tables needs to handle the case where no length information
is available, but can provide an additional, typically faster implementation
if length information is provided by the source. A typical pattern might
be that a consumer can pre-allocate the arrays that should hold the data
from the iterable tables with the right size if length information is
available from the source.

With all this information, a consumer now typically would allocate the
data structures that should hold the converted data. This will almost always
be very consumer specific. Once these data structures have been allocated,
one can actually implement the loop that iterates over the source rows.
To get good performance it is recommended that this loop is implemented
in a new function (behind a function barrier), and that the function with
the loop is type-stable. Often this will require the use of a generated
function that generates code for each column of the source. This can avoid
a loop over the columns while one is iterating over the rows. It is often
key to avoid a loop over columns inside the loop over the rows, given that
columns can have different types, which almost inevitably would lead to a
type instability. 

A good example of a custom consumer of an iterable table is the code
in the `DataTable` integration.

# Creating an iterable table source

There are generally two strategies for turning some custom type into an
iterable table. The first strategy works if one can implement a type-stable
version of `start`, `next` and `done` that iterates elements of type
`NamedTuple`. If that is not feasible, the strategy is to create a new
iterator type. The following two sections describe both approaches.

## Directly implementing the julia base iteration trait

This strategy only works if the type that one wants to expose as an
iterable table has enough information about the strcuture of the table
that one can implement a type stable version of `start`, `next` and
`done`. Typically that requires that one can deduce the names and types
of the columns of the table purely from the type (and type parameters).
For some types that works, but for other types (like `DataFrame`) this
strategy won't work.

If the type one wants to expose as an iterable table allows this strategy,
the implementation is fairly straightforward: one simple needs to implement
the standard julia base iterator interface, and during iteration one should
return `NamedTuple`s for each element. The fields in the `NamedTuple`
correspond to the columns of the table, i.e. the names of the fields are
the column names, and the types of the field are the column types. If the
source supports some notion of missing values, it should return
`NamedTuples` that have fields of type `DataValue{T}`, where `T` is the
data type of the column.

It is important to not only implement `start`, `next` and `end` from the
julia iteration protocoll. Iterable tables also always require that `eltype`
is implemented. Finally, one should either implement `length`, if the source
supports returning the number of rows without expensive computations, or
one should add a method `iteratorsize` that returns `SizeUnknown()` for
the custom type.

The implementation of a type stable `next` method typically requires the
use of generated functions.

## Creating a custom iteration type

For types that don't have enough information encoded in their type to
implement a type stable version of the julia iteration interface, the best
strategy is to create a custom iteration type that implements the julia
iteration interface and has enough information.

For example, for the `MyTable` type one might create a new iterator type
called `MyTableIterator{T}` that holds the type of the `NamedTuple` that
this iterator will return in `T`.

To expose this new iterator type to consumers, one needs to add a method
to the `IterableTables.getiterator` function. This function takes an instance
of the type one wants to expose as an iterable table, and returns a new
type that should actually be used for the iteration itself. For example,
`function IterableTables.getiterator(table::MyTable)` would return an
instance of `MyTableIterator{T}`.

In addition to adding a method to `getiterator`, one must also add methods
to the `IterableTables.isiterable` and `IterableTables.isiterabletable`
functions for the type one wants to turn into an iterable table, in both
cases those methods should return `true`.

The final step is to implement the full julia iteration interface for the
custom iterator type that one returned from `getiterator`. All the same
requirements that were discussed in the previous section apply here as
well.

An example of this strategy is the `DataTable` integration.
