using IterableTables
using TableTraits
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
using Gadfly
using Base.Test  

immutable MyType
end

@testset "IterableTables" begin

include("test_integration_dataframes.jl")
include("test_integration_datastreams.jl")
include("test_integration_datatables.jl")
include("test_integration_statsmodels.jl")
include("test_integration_timeseries.jl")
include("test_integration_typedtables.jl")
include("test_integration_vegalite.jl")
include("test_integration_temporal.jl")
include("test_integration_juliadb.jl")
include("test_integration_gadfly.jl")    

end
