if isdefined(StatsModels, :missing)
    include("test_integration_statsmodels_missing.jl")
else
    include("test_integration_statsmodels_nullable.jl")
end
