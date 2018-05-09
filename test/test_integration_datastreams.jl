if isdefined(DataStreams.Data, :missing)
    include("test_integration_datastreams_missing.jl")
else
    include("test_integration_datastreams_nullable.jl")
end
