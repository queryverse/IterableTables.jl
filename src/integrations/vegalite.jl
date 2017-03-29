@require VegaLite begin

import VegaLite
import DataFrames

@traitfn function VegaLite.data_values{X; IsIterableTable{X}}(data_source::X)
    df = DataFrames.DataFrame(data_source)
    return VegaLite.data_values(df)
end

end
