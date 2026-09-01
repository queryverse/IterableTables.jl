module IterableTables

using Requires, IteratorInterfaceExtensions, TableTraits, TableTraitsUtils
using DataValues

include("integrations/generators.jl")

function __init__()
    @require Temporal="a110ec8f-48c8-5d59-8f7e-f91bc4cc0c3d" include("integrations/temporal.jl")
end

end # module
