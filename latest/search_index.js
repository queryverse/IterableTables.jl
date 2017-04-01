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
    "text": "IterableTables defines a  generic traits interface for tabular data.The package currently has support for the following data sources: DataFrames, DataStreams (including CSV, Feather, SQLite, ODBC), DataTables, IndexedTables, TimeSeries, TypedTables and any iterator who produces elements of type NamedTuple.The following data sinks are currently supported: DataFrames (including things like ModelFrame etc.), DataTables, TypedTables, StatsModels, Gadfly and VegaLite."
},

{
    "location": "index.html#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "This package only works on julia 0.5 and newer. You can add it with:Pkg.clone(\"https://github.com/davidanthoff/IterableTables.jl.git\")Currently you also need to checkout SimpleTraits:Pkg.checkout(\"SimpleTraits\")"
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
    "text": "[TODO]"
},

]}
