module IterableTables

using Requires, IteratorInterfaceExtensions, TableTraits, TableTraitsUtils

# include("integrations/datastreams.jl")
# include("integrations/gadfly.jl")
# include("integrations/timeseries.jl")
# include("integrations/juliadb.jl")
include("integrations/generators.jl")
# include("integrations/temporal.jl")

function __init__()
    @require StatsModels="3eaba693-59b7-5ba5-a881-562e759f1c8d" include("integrations/statsmodels.jl")
end

end # module
