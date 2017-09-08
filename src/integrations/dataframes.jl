@require DataFrames begin

if isdefined(DataFrames, :Nulls)
    include("dataframes-null.jl")
else
    include("dataframes-dataarray.jl")
end

end
