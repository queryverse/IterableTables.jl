@require DataFrames begin

if isdefined(DataFrames, :null)
    include("dataframes-null.jl")
else
    include("dataframes-dataarray.jl")
end

end
