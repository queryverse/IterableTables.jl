using IterableTables
using NamedTuples
using SimpleTraits
using DataFrames
using DataTables
using NullableArrays
using Base.Test

@testset "DataTables" begin

source_dt = DataTable(a=[1,2,3], b=[1.,2.,3.], c=["A","B","C"])

df = DataFrame(source_dt)

@test size(df) == (3,3)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

source_array = [@NT(a=1,b=1.,c="A"), @NT(a=2,b=2.,c="B"), @NT(a=3,b=3.,c="C")]

dt = DataTable(source_array)

@test size(dt) == (3,3)
@test dt[:a] == [1,2,3]
@test dt[:b] == [1.,2.,3.]
@test dt[:c] == ["A","B","C"]

end
