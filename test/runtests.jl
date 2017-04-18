using IterableTables
using NamedTuples
using DataFrames
using DataTables
using DataStreams
using CSV
using SQLite
using FlatBuffers
using Feather
using TimeSeries
using StatsModels
using TypedTables
using VegaLite
using PooledArrays
using IndexedTables
using ParameterizedFunctions
using Base.Test

if VERSION < v"0.6.0-"    
    using Gadfly
end

# This defines a type needed by the differential equations
# test, and that cannot happen in a testset
f_2dlinear_named = @ode_def LotkaVolterra begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a=>1.5 b=>1 c=3 d=1

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
include("test_integration_differentialequations.jl")

if VERSION < v"0.6.0-"
    include("test_integration_gadfly.jl")    
end

end
