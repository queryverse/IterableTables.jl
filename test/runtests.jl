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
using ParameterizedFunctions
using Gadfly
using Base.Test  

# This defines a type needed by the differential equations
# test, and that cannot happen in a testset
f_2dlinear_named = @ode_def LotkaVolterra begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a=>1.5 b=>1 c=3 d=1

immutable MyType
end

@testset "IterableTables" begin

include("test_integration_dataframes.jl")
include("test_integration_datastreams.jl")
include("test_integration_datatables.jl")
include("test_integration_statsmodels.jl")
include("test_integration_timeseries.jl")
include("test_integration_typedtables.jl")
# include("test_integration_vegalite.jl")
include("test_integration_differentialequations.jl")
include("test_integration_temporal.jl")
include("test_integration_juliadb.jl")
include("test_integration_gadfly.jl")    

end
