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
@test isa(dt[:a], NullableArray)
@test isa(dt[:b], NullableArray)
@test isa(dt[:c], NullableArray)
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

data = []
push!(data, [1,2,3])
push!(data, [1.,2.,3.])
push!(data, ["A","B","C"])
source_df_non_nullable = DataFrame(data, [:a,:b,:c])
dt_non_nullable = DataTable(source_df_non_nullable)

@test size(dt_non_nullable) == (3,3)
@test isa(dt_non_nullable[:a], Array)
@test isa(dt_non_nullable[:b], Array)
@test isa(dt_non_nullable[:c], Array)
@test dt_non_nullable[:a] == [1,2,3]
@test dt_non_nullable[:b] == [1.,2.,3.]
@test dt_non_nullable[:c] == ["A","B","C"]

source_array_non_nullable = [@NT(a=1,b=1.,c="A"), @NT(a=2,b=2.,c="B"), @NT(a=3,b=3.,c="C")]
df = DataFrame(source_array_non_nullable)

@test size(df) == (3,3)
@test isa(df[:a], Array)
@test isa(df[:b], Array)
@test isa(df[:c], Array)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

source_array = [@NT(a=Nullable(1),b=Nullable(1.),c=Nullable("A")), @NT(a=Nullable(2),b=Nullable(2.),c=Nullable("B")), @NT(a=Nullable(3),b=Nullable(3.),c=Nullable("C"))]
df = DataFrame(source_array)

@test size(df) == (3,3)
@test isa(df[:a], DataArray)
@test isa(df[:b], DataArray)
@test isa(df[:c], DataArray)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

# TODO add some test beyond just creating a ModelFrame
mf_array = DataFrames.ModelFrame(DataFrames.@formula(a~b), source_array)
mf_dt = DataFrames.ModelFrame(DataFrames.@formula(a~b), dt)

end
