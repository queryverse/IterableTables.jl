@require DataFrames begin

if isdefined(DataFrames, :missing)
    include("dataframes-missing.jl")
else
    include("dataframes-na.jl")
end

end
