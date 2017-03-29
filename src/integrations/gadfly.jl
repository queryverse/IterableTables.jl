@require Gadfly begin

import Gadfly
import DataFrames

@traitfn function Gadfly.plot{X; IsIterableTable{X}}(data_source::X, elements::Gadfly.ElementOrFunctionOrLayers...; mapping...)
    Gadfly.plot(DataFrames.DataFrame(data_source), elements...; mapping...)
end

end
