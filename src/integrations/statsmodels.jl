@require StatsModels begin

if isdefined(StatsModels, :missing)
    include("statsmodels-missing.jl")    
else
    include("statsmodels-nullable.jl")
end

end
