var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "#Overview-1",
    "page": "Introduction",
    "title": "Overview",
    "category": "section",
    "text": "IterableTables defines a  generic interface for tabular data.The package currently has support for the following data sources: DataFrames, DataStreams (including CSV, Feather, SQLite, ODBC), DataTables, IndexedTables, TimeSeries, TypedTables, DifferentialEquations (any DESolution) and any iterator who produces elements of type NamedTuple.The following data sinks are currently supported: DataFrames (including things like ModelFrame etc.), DataStreams (including CSV, Feather), DataTables, IndexedTables, TimeSeries, TypedTables, StatsModels, Gadfly and VegaLite.The package is tightly integrated with Query.jl: Any query that creates a named tuple in the last @select statement (and doesn\'t @collect the results into a data structure) is automatically an iterable table data source, and any of the data sources mentioned above can be queried using Query.jl."
},

{
    "location": "#Installation-1",
    "page": "Introduction",
    "title": "Installation",
    "category": "section",
    "text": "This package only works on julia 0.5 and newer. You can add it with:Pkg.add(\"IterableTables\")"
},

{
    "location": "#Getting-started-1",
    "page": "Introduction",
    "title": "Getting started",
    "category": "section",
    "text": "IterableTables makes it easy to conver between different table types in julia. It also makes it possible to use any table type in situations where packages traditionally expected a DataFrame.For example, if you have a DataFrameusing DataFrames\n\ndf = DataFrame(Name=[\"John\", \"Sally\", \"Jim\"], Age=[34.,25.,67.], Children=[2,0,3])you can easily convert this into any of the supported data sink types by simply constructing a new table type and passing your source df:using DataTables, TypedTables, IndexedTables\n\n# Convert to a DataTable\ndt = DataTable(df)\n\n# Convert to a TypedTable\ntt = Table(df)These conversions work in pretty much any direction. For example you can convert a TypedTable into a DataFrame:new_df = DataFrame(tt)Or you can convert it to a DataTable:new_dt = DataTable(t)The general rule is that you can convert any sink into any source.IterableTables also adds methods to a number of packages that have traditionally only worked with DataFrames that make these packages work with any data source type defined in IterableTables.For example, you can run a regression on any of the source types:using GLM, DataFrames\n\n# Run a regression on a TypedTable\nlm(@formula(Children~Age),tt)\n\n# Run a regression on a DataTable\nlm(@formula(Children~Age),dt)Or you can plot any of these data sources with Gadfly:using Gadfly\n\n# Plot a TypedTable\nplot(tt, x=:Age, y=:Children, Geom.line)\n\n# Plot a DataTable\nplot(dt, x=:Age, y=:Children, Geom.line)Again, this will work with any of the data sources listed above."
},

{
    "location": "userguide/#",
    "page": "User Guide",
    "title": "User Guide",
    "category": "page",
    "text": ""
},

{
    "location": "userguide/#User-Guide-1",
    "page": "User Guide",
    "title": "User Guide",
    "category": "section",
    "text": "This guide describes how one can use IterableTables as a julia user."
},

{
    "location": "userguide/#Overview-1",
    "page": "User Guide",
    "title": "Overview",
    "category": "section",
    "text": "Any of the types that supports the iterable tables interface does so by loading the IterableTables package, nothing else needs to be done.To convert things into a destination type one sometimes needs to obey some special conventions, depending on the destination type, but in general these conversions follow a simple pattern. The following sections describe how to convert and use an iterable table with various packages."
},

{
    "location": "userguide/#DataFrames,-DataTables,-TypedTables-1",
    "page": "User Guide",
    "title": "DataFrames, DataTables, TypedTables",
    "category": "section",
    "text": "For all three packages one can simply pass an iterable table to a constructor call to construct a new instance of that type that holds a copy of the data that was stored in the iterable table. For example, assuming the data source is called ds, one can use the following code:# Construct a DataFrame\ndf = DataFrame(ds)\n\n# Construct a DataTable\ndt = DataTable(ds)\n\n# Construct a TypedTable\ntt = Table(ds)"
},

{
    "location": "userguide/#TimeSeries-1",
    "page": "User Guide",
    "title": "TimeSeries",
    "category": "section",
    "text": "To construct a TimeArray instance, one needs a source that follows a number of rules: 1) it must have a column that is of type TimeType and 2) all other columns must be of one type. With such a source, one can use the following code to create a TimeArray, assuming that ds is an iterable table:ta = TimeArray(ds, timestamp_column=:name_of_timestamp_column)If the column with the timestamp information is named timestamp in the source, one can use a single argument constructor call:ta = TimeArray(ds)"
},

{
    "location": "userguide/#Temporal-1",
    "page": "User Guide",
    "title": "Temporal",
    "category": "section",
    "text": "To construct a TS instance, one needs a source that follows a number of rules: 1) it must have a column that is of type TimeType and 2) all other columns must be of one type. With such a source, one can use the following code to create a TS, assuming that ds is an iterable table:ta = TS(ds, timestamp_column=:name_of_timestamp_column)If the column with the timestamp information is named Index in the source, one can use a single argument constructor call:ta = TS(ds)"
},

{
    "location": "userguide/#IndexedTables-1",
    "page": "User Guide",
    "title": "IndexedTables",
    "category": "section",
    "text": "The simplest way to construct an IndexedTable is to call the one argument constructor on an iterable table ds:it = IndexedTable(ds)In this case the last column in the source will be the data column in the IndexedTable, and all other columns will be index columns.One can manually select the index and data columns by using the keyword arguments idxcols and datacols. Both take a vector of Symbols as arguments. For example, to make the time and region column in a data source the index columns, one would use the following command:it = IndexedTable(ds, idxcols=[:time, :region])In this case all remaining columns will be turned into data columns. If one only specifies the datacols argument, one will create an IndexedTable in which all columns that are not listed in the datacols argument will be turned into index columns. Finally, one can also specify both the idxcols and datacols argument at the same time (and thus even drop columns by noth listing them in either argument list)."
},

{
    "location": "userguide/#JuliaDB-1",
    "page": "User Guide",
    "title": "JuliaDB",
    "category": "section",
    "text": "The simplest way to load any iterable table ds into JuliaDB is to call the distribute function:jdb = distribute(ds)In addition to the arguments that distribute accepts in its normal JuliaDB definition, it also accepts named arguments idxcols and datacols, which have the same meaning as in the InexedTable case."
},

{
    "location": "userguide/#DataStreams-(CSV,-Feather)-1",
    "page": "User Guide",
    "title": "DataStreams (CSV, Feather)",
    "category": "section",
    "text": "To write an iterable table into a CSV or Feather file is slightly more involved. In particular, one must call the function IterableTables.get_datastreams_source to create a DataStream.Source instance that can then be passed to either the CSV.write or Feather.write function.To write an iterable table ds to a CSV file, one would therefor use the following code:CSV.write(\"filename.csv\", IterableTables.get_datastreams_source(ds))And to write an iterable table to a Feather file, one would use the following code:Feather.write(\"filename.csv\", IterableTables.get_datastreams_source(ds))"
},

{
    "location": "userguide/#Gadfly-and-VegaLite-1",
    "page": "User Guide",
    "title": "Gadfly and VegaLite",
    "category": "section",
    "text": "For both plotting packages one can simply pass an iterable table where one would normally have passed a DataFrame.The following example plots an iterable table ds using Gadfly:p = plot(ds, x=:a, y=:b, Geom.line)And this code will plot an iterable table using VegaLite:p = data_values(ds) +\n    mark_line() +\n    encoding_x_quant(:a) +\n    encoding_y_quant(:b)"
},

{
    "location": "userguide/#StatsModels-(and-statistical-models-in-DataFrames)-1",
    "page": "User Guide",
    "title": "StatsModels (and statistical models in DataFrames)",
    "category": "section",
    "text": "For statistical models one can use an iterable table instead of a DataFrame. Under the hood this is achieved by providing a constructor for ModelFrame that takes an iterable table, and by providing methods for the fit function that accept an iterable table instead of a DataFrame. For most users this implies that one can e.g. simply pass an iterable table to the lm and glm function in the GLM package (assuming ds is any iterable table):OLS = glm(@formula(Y ~ X), ds, Normal(), IdentityLink())"
},

{
    "location": "userguide/#CSVFiles,-FeatherFiles,-ExcelFiles-and-StatFiles-1",
    "page": "User Guide",
    "title": "CSVFiles, FeatherFiles, ExcelFiles and StatFiles",
    "category": "section",
    "text": "See the README for CSVFiles.jl, ExcelFiles.jl, FeatherFiles.jl and StatFiles.jl for documentation."
},

{
    "location": "integrationguide/#",
    "page": "Integration Guide",
    "title": "Integration Guide",
    "category": "page",
    "text": ""
},

{
    "location": "integrationguide/#Integration-Guide-1",
    "page": "Integration Guide",
    "title": "Integration Guide",
    "category": "section",
    "text": "This guide describes how package authors can integrate their own packages with the IterableTables ecosystem. Specifically, it explains how one can turn a type into an iterable table and how one can write code that consumes iterable tables."
},

{
    "location": "integrationguide/#Overview-1",
    "page": "Integration Guide",
    "title": "Overview",
    "category": "section",
    "text": "For now I recommend that all integrations with IterableTables should live in the IterableTables package. This is a temporary solution until the interface in IterableTables is more stable, at which point integrations will be moved into the packages that they integrate. So new integrations should at this point ideally be submitted as pull requests against the IterableTables repository. Specifically, each integration should be put into a file in the folder src/integrations, and the filename should be the name of the package that is being integrated. The code in that file should live in a @require block (see one of the existing integrations for an example)."
},

{
    "location": "integrationguide/#Consuming-iterable-tables-1",
    "page": "Integration Guide",
    "title": "Consuming iterable tables",
    "category": "section",
    "text": "One cannot dispatch on an iterable table because iterable tables don\'t have a common super type. Instead one has to add a method that takes any type as an argument to consume an iterable table. For conversions between types it is recommended that one adds a constructor that takes one argument without any type restriction that can convert an iterable table into the target type. For example, if one has added a new table type called MyTable, one would add a constructor with this method signature for this type: function MyTable(iterable_table). For other situations, for example a plotting function, one also would add a method without any type restriction, for example plot(iterable_table).The first step inside any function that consumes iterable tables is to check whether the argument that was passed is actually an iterable table or not. This can easily be done with the isiterabletable function. For example, the constructor for a new table type might start like this:function MyTable(source)\n    isiterabletable(source) || error(\"Argument is not an iterable table.\")\n\n    # Code that converts things follows\nendOnce it has been established that the argument is actually an iterable table there are multiple ways to proceed. The following two sections describe two options, which one is appropriate for a given situation depends on a variety of factors."
},

{
    "location": "integrationguide/#Reusing-an-existing-consumer-of-iterable-tables-1",
    "page": "Integration Guide",
    "title": "Reusing an existing consumer of iterable tables",
    "category": "section",
    "text": "This option is by far the simplest way to add support for consuming an iterable table. Essentially the strategy is to reuse the conversion implementation of some other type. For example, one can simply convert the iterable table into a DataFrame right after one has checked that the argument of the function is actually an iterable table. Once the iterable table is converted to a DataFrame, one can use the standard API of DataFrames to proceed. This strategy is especially simple for packages that already support interaction with DataFrames (or any of the other table types supported by IterableTables). The code for the MyTable constructor might look like this:function MyTable(source)\n    isiterabletable(source) || error(\"Argument is not an iterable table.\")\n\n    df = DataFrame(source)\n    return MyTable(df)\nendThis assumes that MyTable has another constructor that accepts a DataFrame.Currently the most efficient table type for this kind of conversion is the DataTable type from the DataTables.jl package. How efficient is this strategy in general? It really depends what is happening in the next step with say the DataTable one constructed. If the data will be copied into yet another data structure after it has been converted to a DataTable, one has added at least one unnecessary memory allocation in the conversion. For such a situation it is probably more efficient to manually code a complete version, as described in the next section. If, on the other hand, one for example requires a vector of values for each column of the table, this approach can be quite efficient: one can just access the vector in the DataTable and operate on that."
},

{
    "location": "integrationguide/#Coding-a-complete-conversion-1",
    "page": "Integration Guide",
    "title": "Coding a complete conversion",
    "category": "section",
    "text": "Coding a custom conversion is more work than reusing an existing consumer of iterable tables, but it provides more flexibility.In general, a custom conversion function also needs to start with a call to isiterable to check whether one actually has an iterable table. The second step in any custom conversion function is to all the getiterator function on the iterable table. This will return an instance of a type that implements the standard julia iterator interface, i.e. one can call start, next and done on the instance that is returned by getiterator. For some iterable tables getiterator will just return the argument that one has passed to it, but for other iterable tables it will return an instance of a different type.getiterator is generally not a type stable function. Given that this function is generally only called once per conversion this hopefully is not a huge performance issue. The functions that really need to be type-stable are start, next and done because they will be called for every row of the table that is to be converted. In general, these three functions will be type stable for the type of the return value of getiterator. But given that getiterator is not type stable, one needs to use a function barrier to make sure the three iteration functions are called from a type stable function.The next step in a custom conversion function is typically to find out what columns the iterable table has. The helper functions IterableTables.column_types and IterableTables.column_names provide this functionality (note that these are not part of the official iterable tables interface, they are simply helper functions that make it easier to find this information). Both functions need to be called with the return value of getiterator as the argument. IterableTables.column_types returns a vector of Types that are the element types of the columns of the iterable table. IterableTables.column_names returns a vector of Symbols with the names of the columns.Custom conversion functions can at this point optionally check whether the iterable table implements the length function by checking whether Base.iteratorsize(typeof(iter))==Base.HasLength() (this is part of the standard iteration protocol). It is important to note that every consumer of iterable tables needs to handle the case where no length information is available, but can provide an additional, typically faster implementation if length information is provided by the source. A typical pattern might be that a consumer can pre-allocate the arrays that should hold the data from the iterable tables with the right size if length information is available from the source.With all this information, a consumer now typically would allocate the data structures that should hold the converted data. This will almost always be very consumer specific. Once these data structures have been allocated, one can actually implement the loop that iterates over the source rows. To get good performance it is recommended that this loop is implemented in a new function (behind a function barrier), and that the function with the loop is type-stable. Often this will require the use of a generated function that generates code for each column of the source. This can avoid a loop over the columns while one is iterating over the rows. It is often key to avoid a loop over columns inside the loop over the rows, given that columns can have different types, which almost inevitably would lead to a type instability. A good example of a custom consumer of an iterable table is the code in the DataTable integration."
},

{
    "location": "integrationguide/#Creating-an-iterable-table-source-1",
    "page": "Integration Guide",
    "title": "Creating an iterable table source",
    "category": "section",
    "text": "There are generally two strategies for turning some custom type into an iterable table. The first strategy works if one can implement a type-stable version of start, next and done that iterates elements of type NamedTuple. If that is not feasible, the strategy is to create a new iterator type. The following two sections describe both approaches."
},

{
    "location": "integrationguide/#Directly-implementing-the-julia-base-iteration-trait-1",
    "page": "Integration Guide",
    "title": "Directly implementing the julia base iteration trait",
    "category": "section",
    "text": "This strategy only works if the type that one wants to expose as an iterable table has enough information about the strcuture of the table that one can implement a type stable version of start, next and done. Typically that requires that one can deduce the names and types of the columns of the table purely from the type (and type parameters). For some types that works, but for other types (like DataFrame) this strategy won\'t work.If the type one wants to expose as an iterable table allows this strategy, the implementation is fairly straightforward: one simple needs to implement the standard julia base iterator interface, and during iteration one should return NamedTuples for each element. The fields in the NamedTuple correspond to the columns of the table, i.e. the names of the fields are the column names, and the types of the field are the column types. If the source supports some notion of missing values, it should return NamedTuples that have fields of type DataValue{T}, where T is the data type of the column.It is important to not only implement start, next and end from the julia iteration protocoll. Iterable tables also always require that eltype is implemented. Finally, one should either implement length, if the source supports returning the number of rows without expensive computations, or one should add a method iteratorsize that returns SizeUnknown() for the custom type.The implementation of a type stable next method typically requires the use of generated functions."
},

{
    "location": "integrationguide/#Creating-a-custom-iteration-type-1",
    "page": "Integration Guide",
    "title": "Creating a custom iteration type",
    "category": "section",
    "text": "For types that don\'t have enough information encoded in their type to implement a type stable version of the julia iteration interface, the best strategy is to create a custom iteration type that implements the julia iteration interface and has enough information.For example, for the MyTable type one might create a new iterator type called MyTableIterator{T} that holds the type of the NamedTuple that this iterator will return in T.To expose this new iterator type to consumers, one needs to add a method to the IterableTables.getiterator function. This function takes an instance of the type one wants to expose as an iterable table, and returns a new type that should actually be used for the iteration itself. For example, function IterableTables.getiterator(table::MyTable) would return an instance of MyTableIterator{T}.In addition to adding a method to getiterator, one must also add methods to the IterableTables.isiterable and IterableTables.isiterabletable functions for the type one wants to turn into an iterable table, in both cases those methods should return true.The final step is to implement the full julia iteration interface for the custom iterator type that one returned from getiterator. All the same requirements that were discussed in the previous section apply here as well.An example of this strategy is the DataTable integration."
},

{
    "location": "developerguide/#",
    "page": "Developer Guide",
    "title": "Developer Guide",
    "category": "page",
    "text": ""
},

{
    "location": "developerguide/#Developer-Guide-1",
    "page": "Developer Guide",
    "title": "Developer Guide",
    "category": "section",
    "text": "This guide explains the design of IterableTables."
},

{
    "location": "developerguide/#Overview-1",
    "page": "Developer Guide",
    "title": "Overview",
    "category": "section",
    "text": "The iterable table interface has two core parts:A simple way for a type to signal that it is an iterable table. It also provides a way for consumers of an iterable table to check whether a particular value is an iterable table and a convention on how to start the iteration of the table.\nA number of conventions how tabular data should be iterated.In addition the package provides a number of small helper functions that make it easier to implement an iterable table consumer."
},

{
    "location": "developerguide/#Signaling-and-detection-of-iterable-tables-1",
    "page": "Developer Guide",
    "title": "Signaling and detection of iterable tables",
    "category": "section",
    "text": "In general a type is an iterable table if it can be iterated and if the element type that is returned during iteration is a NamedTuple.In a slight twist of the standard julia iteration interface, iterable tables introduces one extra step into this simple story: consumers should never iterate a data source directly by calling the start function on it, instead they should always call getiterator on the data source, and then use the standard julia iterator protocol on the value return by getiterator.This indirection enables us to implement type stable iterator functions start, next and done for data sources that don\'t incorporate enough information in their type for type stable versions of these three functions (e.g. DataFrames). IterableTables provides a default implementation of getiterator that just returns that data source itself. For data sources that have enough type information to implement type stable versions of the iteration functions, this default implementation of getiterator works well. For other types, like DataFrame, package authors can provide their own getiterator implementation that returns a value of some new type that has enough information encoded in its type parameters so that one can implement type stable versions of start, next and done.The function isiterable enables a consumer to check whether any arbitrary value is iterable, in the sense that getiterator will return something that can be iterated. The default isiterable(x::Any) implementation checks whether a suitable start method for the type of x exists. Types that use the indirection described in the previous paragraph might not implement a start method, though, instead they will return a type for which start is implemented from the getiterator function. Such types should manually add a method to isiterable that returns true for values of their type, so that consumers can detect that a call to getiterator is going to be successful.The final function in the detection and signaling interface of IterableTables is isiterabletable(x). The fallback implementation for this method will check whether isiterable(x) returns true, and whether eltype(x) returns a NamedTuple. For types that don\'t provide their own getiterator method this will signal the correct behavior to consumers. For types that use the indirection method described above by providing their own getiterator method, package authors should provide their own isiterable method that returns true if that data source will iterate values of type NamedTuples from the value returned by getiterator."
},

{
    "location": "developerguide/#Iteration-conventions-1",
    "page": "Developer Guide",
    "title": "Iteration conventions",
    "category": "section",
    "text": "Any iterable table should return elements of type NamedTuple. Each column of the source table should be encoded as a field in the named tuple, and the type of that field in the named tuple should reflect the data type of the column in the table. If a column can hold missing values, the type of the corresponding field in the NamedTuple should be a DataValue{T} where T is the data type of the column."
},

]}
