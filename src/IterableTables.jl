__precompile__()
module IterableTables

using TableTraits, NamedTuples, Requires

include("integrations/dataframes.jl")
include("integrations/datastreams.jl")
include("integrations/datatables.jl")
include("integrations/gadfly.jl")
include("integrations/statsmodels.jl")
include("integrations/timeseries.jl")
include("integrations/typedtables.jl")
include("integrations/vegalite.jl")
include("integrations/differentialequations.jl")
include("integrations/juliadb.jl")
include("integrations/generators.jl")
include("integrations/temporal.jl")

end # module
