using DataFrames
using IterableTables
using TableTraits
using NamedTuples
using GLM
using Nulls
using Base.Test

@testset "DataFrames" begin

source_df = DataFrame(a=Union{Int, Null}[1,2,3], b=Union{Float64, Null}[1.,2.,3.], c=Union{String, Null}["A","B","C"])

@test isiterable(source_df) == true

dt = DataFrame(source_df)

@test size(dt) == (3, 3)
@test eltype(dt[:a]) == Union{Int, Null}
@test eltype(dt[:b]) == Union{Float64, Null}
@test eltype(dt[:c]) == Union{String, Null}
@test !isnull(dt[1,:a])
@test !isnull(dt[1,:b])
@test !isnull(dt[1,:c])
@test !isnull(dt[2,:a])
@test !isnull(dt[2,:b])
@test !isnull(dt[2,:c])
@test !isnull(dt[3,:a])
@test !isnull(dt[3,:b])
@test !isnull(dt[3,:c])
@test dt[1,:a] == 1
@test dt[2,:a] == 2
@test dt[3,:a] == 3
@test dt[1,:b] == 1.
@test dt[2,:b] == 2.
@test dt[3,:b] == 3.
@test dt[1,:c] == "A"
@test dt[2,:c] == "B"
@test dt[3,:c] == "C"

source_df_non_nullable = DataFrame(a=[1,2,3], b=[1.,2.,3.], c=["A","B","C"])
dt_non_nullable = DataFrame(source_df_non_nullable)

@test size(dt_non_nullable) == (3,3)
@test eltype(dt_non_nullable[:a]) == Int
@test eltype(dt_non_nullable[:b]) == Float64
@test eltype(dt_non_nullable[:c]) == String
@test dt_non_nullable[:a] == [1,2,3]
@test dt_non_nullable[:b] == [1.,2.,3.]
@test dt_non_nullable[:c] == ["A","B","C"]

source_array_non_nullable = @NT(a::Int, b::Union{Float64, Null}, c::String)[@NT(a=1,b=1.,c="A"), @NT(a=2,b=null,c="B"), @NT(a=3,b=3.,c="C")]
source_array_non_nullable = NamedTuple{(:a,:b,:c), Tuple{Int, Union{Float64, Null}, String}}[(a=1,b=1.,c="A"), (a=2,b=null,c="B"), (a=3,b=3.,c="C")]
df = DataFrame(source_array_non_nullable)

@test size(df) == (3,3)
@test isa(df[:a], Array)
@test isa(df[:b], Array)
@test isa(df[:c], Array)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

source_array = [@NT(a=DataValue(1),b=DataValue(1.),c=DataValue("A")), @NT(a=DataValue(2),b=DataValue(2.),c=DataValue("B")), @NT(a=DataValue(3),b=DataValue(3.),c=DataValue("C"))]
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

lm(DataFrames.@formula(a~b), dt)

# This tests for a specific bug we once had
df_with_sub_list = DataFrame(name=["John", "Sally", "Kirk"], numberoftoys=[[4; 3; 2], [2; 2; 4; 5; 1], [2; 2]])
dt = DataFrame(df_with_sub_list)
@test size(dt) == (3,2)

end




julia> using NamedTuples
INFO: Recompiling stale cache file /Users/jacobquinn/.julia/lib/v0.6/NamedTuples.ji for module NamedTuples.

julia> struct Empty end

julia> nt = @NT(a::Empty, b::Int)
ERROR: UndefVarError: Empty not defined


ulia> using NamedTuples
INFO: Recompiling stale cache file /Users/jacobquinn/.julia/lib/v0.6/NamedTuples.ji for module NamedTuples.

julia> struct Empty end

julia> nt = @NT(a::Empty, b::Int)
(sym, typ, val) = (:a, :Empty, nothing)
(sym, typ, val) = (:b, :Int, nothing)
NamedTuples._NT_a_b{Empty,Int64}
