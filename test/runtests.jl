using IterableTables
using NamedTuples
using SimpleTraits
using Base.Test

@testset "IterableTables" begin

@testset "Core" begin

table_array = [@NT(a=1), @NT(a=2)]
other_array = [1,2,3]

@test istrait(IsIterableTable{typeof(table_array)})
@test !istrait(IsIterableTable{typeof(other_array)})

end

include("test_integration_dataframes.jl")
include("test_integration_datastreams.jl")
include("test_integration_datatables.jl")
include("test_integration_gadfly.jl")
include("test_integration_indexedtables.jl")
include("test_integration_statsmodels.jl")
include("test_integration_timeseries.jl")
include("test_integration_typedtables.jl")
include("test_integration_vegalite.jl")

end
