using TestItemRunner

include("test_integration_dataframes.jl")
include("test_integration_statsmodels.jl")
include("test_integration_timeseries.jl")
include("test_integration_temporal.jl")
# include("test_integration_juliadb.jl")
# include("test_integration_gadfly.jl")

@run_package_tests
