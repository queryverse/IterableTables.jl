using IterableTables
using NamedTuples
using VegaLite
using DataTables
using Base.Test

@testset "VegaLite" begin

source_dt = DataTable(a=[1,2,3], b=[4,2,6])

p = data_values(source_dt) +
    mark_line() +
    encoding_x_quant(:a) +
    encoding_y_quant(:b)

@test isa(p, VegaLite.VegaLiteVis)

end
