using IterableTables
using NamedTuples
using Gadfly
using DataTables
using Base.Test

@testset "Gadfly" begin

source_dt = DataTable(a=[1,2,3], b=[4,2,6])

p = Gadfly.plot(source_dt, x=:a, y=:b, Geom.line)

@test isa(p, Gadfly.Plot)

end
