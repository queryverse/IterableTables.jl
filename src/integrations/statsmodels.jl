function StatsModels.ModelFrame(f::StatsModels.Formula, d; kwargs...)
    TableTraits.isiterabletable(d) || error()
    StatsModels.ModelFrame(f, DataFrames.DataFrame(d); kwargs...)
end

function StatsModels.StatsBase.fit(::Type{T}, f::StatsModels.Formula, d, args...; contrasts::Dict = Dict(), kwargs...) where
                       T<:Union{ StatsModels.StatsBase.StatisticalModel,  StatsModels.StatsBase.RegressionModel}
    TableTraits.isiterabletable(d) || error()
    StatsModels.StatsBase.fit(T, f, DataFrames.DataFrame(d), args...; contrasts = contrasts, kwargs...)
end
