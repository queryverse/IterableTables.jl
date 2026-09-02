using TestItemRunner

include("test_generators.jl")
include("test_integration_dataframes.jl")
include("test_integration_statsmodels.jl")
include("test_integration_timeseries.jl")
include("test_integration_temporal.jl")
include("test_integration_csvfiles.jl")

@run_package_tests
