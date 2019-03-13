using Test  

struct MyType
end

@testset "IterableTables" begin

include("test_integration_dataframes.jl")
include("test_integration_statsmodels.jl")
include("test_integration_timeseries.jl")
include("test_integration_temporal.jl")
# include("test_integration_juliadb.jl")
# include("test_integration_gadfly.jl")    

end
