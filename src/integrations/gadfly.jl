using TableTraits

import Gadfly
import DataFrames

function Gadfly.plot(data_source, elements::Gadfly.ElementOrFunctionOrLayers...; mapping...)
    return Gadfly.plot(DataFrames.DataFrame(data_source), elements...; mapping...)
end
