using IterableTables
using NamedTuples
using SimpleTraits
using DataFrames
using DataTables
using NullableArrays
using Base.Test

@testset "DataFrames" begin

source_df = DataFrame(a=[1,2,3], b=[1.,2.,3.], c=["A","B","C"])

dt = DataTable(source_df)

@test size(dt) == (3,3)
@test !isnull(dt[1,:a])
@test !isnull(dt[1,:b])
@test !isnull(dt[1,:c])
@test !isnull(dt[2,:a])
@test !isnull(dt[2,:b])
@test !isnull(dt[2,:c])
@test !isnull(dt[3,:a])
@test !isnull(dt[3,:b])
@test !isnull(dt[3,:c])
@test get(dt[1,:a]) == 1
@test get(dt[2,:a]) == 2
@test get(dt[3,:a]) == 3
@test get(dt[1,:b]) == 1.
@test get(dt[2,:b]) == 2.
@test get(dt[3,:b]) == 3.
@test get(dt[1,:c]) == "A"
@test get(dt[2,:c]) == "B"
@test get(dt[3,:c]) == "C"

source_array = [@NT(a=1,b=1.,c="A"), @NT(a=2,b=2.,c="B"), @NT(a=3,b=3.,c="C")]

df = DataFrame(source_array)

@test size(df) == (3,3)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

end
