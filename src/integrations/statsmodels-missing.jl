using TableTraits

import DataFrames
import StatsBase

function StatsModels.ModelFrame(f::StatsModels.Formula, d; kwargs...)
    isiterabletable(d) || error()
    StatsModels.ModelFrame(f, DataFrames.DataFrame(d); kwargs...)
end

function StatsBase.fit(::Type{T}, f::StatsModels.Formula, d, args...; contrasts::Dict = Dict(), kwargs...) where
                       T<:Union{StatsBase.StatisticalModel, StatsBase.RegressionModel}
    isiterabletable(d) || error()
    StatsBase.fit(T, f, DataFrames.DataFrame(d), args...; contrasts = contrasts, kwargs...)
end
