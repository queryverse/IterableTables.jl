module IterableTables

using Requires, IteratorInterfaceExtensions, TableTraits, TableTraitsUtils
using DataValues

# include("integrations/gadfly.jl")
# include("integrations/juliadb.jl")
include("integrations/generators.jl")

function __init__()
    @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" if !isdefined(DataFrames, :Tables)
        include("integrations/dataframes.jl")
    end
    @require StatsModels="3eaba693-59b7-5ba5-a881-562e759f1c8d" if !isdefined(StatsModels, :Tables)
        include("integrations/statsmodels.jl")
    end
    @require TimeSeries="9e3dc215-6440-5c97-bce1-76c03772f85e" if !isdefined(TimeSeries, :Tables)
        include("integrations/timeseries.jl")
    end
    @require Temporal="a110ec8f-48c8-5d59-8f7e-f91bc4cc0c3d" include("integrations/temporal.jl")
end

end # module
