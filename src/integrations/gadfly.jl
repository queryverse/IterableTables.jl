@require Gadfly begin

import Gadfly
import DataFrames

function Gadfly.plot(data_source, elements::Gadfly.ElementOrFunctionOrLayers...; mapping...)
    isiterabletable(data_source) || error()
    Gadfly.plot(DataFrames.DataFrame(data_source), elements...; mapping...)
end

end
