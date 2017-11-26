using TableTraits

import DataFrames
import StatsBase

function StatsModels.ModelFrame(f::StatsModels.Formula, d; kwargs...)
    isiterabletable(d) || error()
    StatsModels.ModelFrame(f, DataFrames.DataFrame(d); kwargs...)
end

function StatsBase.fit{T<:StatsBase.StatisticalModel}(::Type{T}, f::StatsModels.Formula, source, args...; contrasts::Dict = Dict(), kwargs...)
    isiterabletable(source) || error()
    mf = StatsModels.ModelFrame(f, source, contrasts=contrasts)
    mm = StatsModels.ModelMatrix(mf)
    y = StatsBase.model_response(mf)
    StatsModels.DataFrameStatisticalModel(StatsBase.fit(T, mm.m, y, args...; kwargs...), mf, mm)
end

function StatsBase.fit{T<:StatsBase.RegressionModel}(::Type{T}, f::StatsModels.Formula, source, args...; contrasts::Dict = Dict(), kwargs...)
    isiterabletable(source) || error()
    mf = StatsModels.ModelFrame(f, source, contrasts=contrasts)
    mm = StatsModels.ModelMatrix(mf)
    y = StatsBase.model_response(mf)
    StatsModels.DataFrameRegressionModel(StatsBase.fit(T, mm.m, y, args...; kwargs...), mf, mm)
end
