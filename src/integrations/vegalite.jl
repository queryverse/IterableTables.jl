@require VegaLite begin
using TableTraits
import VegaLite
import DataFrames

function VegaLite.data_values(data_source)
    isiterabletable(data_source) || error()

    df = DataFrames.DataFrame(data_source)
    return VegaLite.data_values(df)
end

end
