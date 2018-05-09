@require DataStreams begin

if isdefined(DataStreams.Data, :missing)
    include("datastreams-missing.jl")
else
    include("datastreams-nullable.jl")
end

end
