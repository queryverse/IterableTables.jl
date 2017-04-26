var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Overview-1",
    "page": "Introduction",
    "title": "Overview",
    "category": "section",
    "text": "IterableTables defines a  generic interface for tabular data.The package currently has support for the following data sources: DataFrames, DataStreams (including CSV, Feather, SQLite, ODBC), DataTables, IndexedTables, TimeSeries, TypedTables, DifferentialEquations (any DESolution) and any iterator who produces elements of type NamedTuple.The following data sinks are currently supported: DataFrames (including things like ModelFrame etc.), DataStreams (including CSV, Feather), DataTables, IndexedTables, TimeSeries, TypedTables, StatsModels, Gadfly and VegaLite.The package is tightly integrated with Query.jl: Any query that creates a named tuple in the last @select statement (and doesn't @collect the results into a data structure) is automatically an iterable table data source, and any of the data sources mentioned above can be queried using Query.jl."
},

{
    "location": "index.html#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "This package only works on julia 0.5 and newer. You can add it with:Pkg.clone(\"https://github.com/davidanthoff/IterableTables.jl.git\")"
},

{
    "location": "index.html#Getting-started-1",
    "page": "Introduction",
    "title": "Getting started",
    "category": "section",
    "text": "IterableTables makes it easy to conver between different table types in julia. It also makes it possible to use any table type in situations where packages traditionally expected a DataFrame.For example, if you have a DataFrameusing DataFrames\n\ndf = DataFrame(Name=[\"John\", \"Sally\", \"Jim\"], Age=[34.,25.,67.], Children=[2,0,3])you can easily convert this into any of the supported data sink types by simply constructing a new table type and passing your source df:using DataTables, TypedTables, IndexedTables\n\n# Convert to a DataTable\ndt = DataTable(df)\n\n# Convert to a TypedTable\ntt = Table(df)These conversions work in pretty much any direction. For example you can convert a TypedTable into a DataFrame:new_df = DataFrame(tt)Or you can convert it to a DataTable:new_dt = DataTable(t)The general rule is that you can convert any sink into any source.IterableTables also adds methods to a number of packages that have traditionally only worked with DataFrames that make these packages work with any data source type defined in IterableTables.For example, you can run a regression on any of the source types:using GLM, DataFrames\n\n# Run a regression on a TypedTable\nlm(@formula(Children~Age),tt)\n\n# Run a regression on a DataTable\nlm(@formula(Children~Age),dt)Or you can plot any of these data sources with Gadfly:using Gadfly\n\n# Plot a TypedTable\nplot(tt, x=:Age, y=:Children, Geom.line)\n\n# Plot a DataTable\nplot(dt, x=:Age, y=:Children, Geom.line)Again, this will work with any of the data sources listed above."
},

{
    "location": "userguide.html#",
    "page": "User Guide",
    "title": "User Guide",
    "category": "page",
    "text": ""
},

{
    "location": "userguide.html#User-Guide-1",
    "page": "User Guide",
    "title": "User Guide",
    "category": "section",
    "text": "This guide describes how one can use IterableTables as a julia user."
},

{
    "location": "userguide.html#Overview-1",
    "page": "User Guide",
    "title": "Overview",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "integrationguide.html#",
    "page": "Integration Guide",
    "title": "Integration Guide",
    "category": "page",
    "text": ""
},

{
    "location": "integrationguide.html#Integration-Guide-1",
    "page": "Integration Guide",
    "title": "Integration Guide",
    "category": "section",
    "text": "This guide describes how package authors can integrate their own packages with the IterableTables ecosystem. Specifically, it explains how one can turn a type into an iterable table and how one can write code that consumes iterable tables."
},

{
    "location": "integrationguide.html#Overview-1",
    "page": "Integration Guide",
    "title": "Overview",
    "category": "section",
    "text": "[TODO]"
},

{
    "location": "developerguide.html#",
    "page": "Developer Guide",
    "title": "Developer Guide",
    "category": "page",
    "text": ""
},

{
    "location": "developerguide.html#Developer-Guide-1",
    "page": "Developer Guide",
    "title": "Developer Guide",
    "category": "section",
    "text": "This guide explains the design of IterableTables."
},

{
    "location": "developerguide.html#Overview-1",
    "page": "Developer Guide",
    "title": "Overview",
    "category": "section",
    "text": "The iterable table interface has two core parts:A simple way for a type to signal that it is an iterable table. It also provides a way for consumers of an iterable table to check whether a particular value is an iterable table and a convention on how to start the iteration of the table.\nA number of conventions how tabular data should be iterated.In addition the package provides a number of small helper functions that make it easier to implement an iterable table consumer."
},

{
    "location": "developerguide.html#Signaling-and-detection-of-iterable-tables-1",
    "page": "Developer Guide",
    "title": "Signaling and detection of iterable tables",
    "category": "section",
    "text": "In general a type is an iterable table if it can be iterated and if the element type that is returned during iteration is a NamedTuple.In a slight twist of the standard julia iteration interface, iterable tables introduces one extra step into this simple story: consumers should never iterate a data source directly by calling the start function on it, instead they should always call getiterator on the data source, and then use the standard julia iterator protocol on the value return by getiterator.This indirection enables us to implement type stable iterator functions start, next and done for data sources that don't incorporate enough information in their type for type stable versions of these three functions (e.g. DataFrames). IterableTables provides a default implementation of getiterator that just returns that data source itself. For data sources that have enough type information to implement type stable versions of the iteration functions, this default implementation of getiterator works well. For other types, like DataFrame, package authors can provide their own getiterator implementation that returns a value of some new type that has enough information encoded in its type parameters so that one can implement type stable versions of start, next and done.The function isiterable enables a consumer to check whether any arbitrary value is iterable, in the sense that getiterator will return something that can be iterated. The default isiterable(x::Any) implementation checks whether a suitable start method for the type of x exists. Types that use the indirection described in the previous paragraph might not implement a start method, though, instead they will return a type for which start is implemented from the getiterator function. Such types should manually add a method to isiterable that returns true for values of their type, so that consumers can detect that a call to getiterator is going to be successful.The final function in the detection and signaling interface of IterableTables is isiterabletable(x). The fallback implementation for this method will check whether isiterable(x) returns true, and whether eltype(x) returns a NamedTuple. For types that don't provide their own getiterator method this will signal the correct behavior to consumers. For types that use the indirection method described above by providing their own getiterator method, package authors should provide their own isiterable method that returns true if that data source will iterate values of type NamedTuples from the value returned by getiterator."
},

{
    "location": "developerguide.html#Iteration-conventions-1",
    "page": "Developer Guide",
    "title": "Iteration conventions",
    "category": "section",
    "text": "Any iterable table should return elements of type NamedTuple. Each column of the source table should be encoded as a field in the named tuple, and the type of that field in the named tuple should reflect the data type of the column in the table. If a column can hold missing values, the type of the corresponding field in the NamedTuple should be a Nullable{T} where T is the data type of the column."
},

]}
