using IterableTables
using NamedTuples
using DataFrames
using DataTables
using CSV
using SQLite
using Feather
using TimeSeries
using StatsModels
using TypedTables
using VegaLite
using IndexedTables
using Base.Test

if VERSION < v"0.6.0-"    
    using Gadfly
end

@testset "IterableTables" begin

@testset "Core" begin

table_array = [@NT(a=1), @NT(a=2)]
other_array = [1,2,3]

@test isiterabletable(table_array)
@test !isiterabletable(other_array)

iter = getiterator(table_array)
@test IterableTables.column_names(iter) == [:a]
@test IterableTables.column_types(iter) == [Int]
@test IterableTables.column_count(iter) == 1

end

include("test_integration_dataframes.jl")
include("test_integration_datastreams.jl")
include("test_integration_datatables.jl")
include("test_integration_statsmodels.jl")
include("test_integration_timeseries.jl")
include("test_integration_typedtables.jl")
include("test_integration_vegalite.jl")
include("test_integration_indexedtables.jl")

if VERSION < v"0.6.0-"
    include("test_integration_gadfly.jl")    
end

end
