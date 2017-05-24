# Developer Guide

This guide explains the design of `IterableTables`.

## Overview

The iterable table interface has two core parts:

1. A simple way for a type to signal that it is an iterable table. It also provides a way for consumers of an iterable table to check whether a particular value is an iterable table and a convention on how to start the iteration of the table.
2. A number of conventions how tabular data should be iterated.

In addition the package provides a number of small helper functions that make it easier to implement an iterable table consumer.

## Signaling and detection of iterable tables

In general a type is an iterable table if it can be iterated and if the element type that is returned during iteration is a `NamedTuple`.

In a slight twist of the standard julia iteration interface, iterable tables introduces one extra step into this simple story: consumers should never iterate a data source directly by calling the `start` function on it, instead they should always call `getiterator` on the data source, and then use the standard julia iterator protocol on the value return by `getiterator`.

This indirection enables us to implement type stable iterator functions `start`, `next` and `done` for data sources that don't incorporate enough information in their type for type stable versions of these three functions (e.g. `DataFrame`s). `IterableTables` provides a default implementation of `getiterator` that just returns that data source itself. For data sources that have enough type information to implement type stable versions of the iteration functions, this default implementation of `getiterator` works well. For other types, like `DataFrame`, package authors can provide their own `getiterator` implementation that returns a value of some new type that has enough information encoded in its type parameters so that one can implement type stable versions of `start`, `next` and `done`.

The function `isiterable` enables a consumer to check whether any arbitrary value is iterable, in the sense that `getiterator` will return something that can be iterated. The default `isiterable(x::Any)` implementation checks whether a suitable `start` method for the type of `x` exists. Types that use the indirection described in the previous paragraph might not implement a `start` method, though, instead they will return a type for which `start` is implemented from the `getiterator` function. Such types should manually add a method to `isiterable` that returns `true` for values of their type, so that consumers can detect that a call to `getiterator` is going to be successful.

The final function in the detection and signaling interface of `IterableTables` is `isiterabletable(x)`. The fallback implementation for this method will check whether `isiterable(x)` returns `true`, and whether `eltype(x)` returns a `NamedTuple`. For types that don't provide their own `getiterator` method this will signal the correct behavior to consumers. For types that use the indirection method described above by providing their own `getiterator` method, package authors should provide their own `isiterable` method that returns `true` if that data source will iterate values of type `NamedTuples` from the value returned by `getiterator`.

## Iteration conventions

Any iterable table should return elements of type `NamedTuple`. Each column of the source table should be encoded as a field in the named tuple, and the type of that field in the named tuple should reflect the data type of the column in the table. If a column can hold missing values, the type of the corresponding field in the `NamedTuple` should be a `DataValue{T}` where `T` is the data type of the column.
