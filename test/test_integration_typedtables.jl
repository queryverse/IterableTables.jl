using IterableTables
using NamedTuples
using SimpleTraits
using TypedTables
using DataFrames
using NullableArrays
using Base.Test

@testset "TypedTables" begin

source_tt = @Table(a=Nullable{Int}[1,2,3], b=Nullable{Float64}[1.,2.,3.], c=Nullable{String}["A","B","C"])
df = DataFrame(source_tt)

@test size(df) == (3,3)
@test isa(df[:a], DataArray)
@test isa(df[:b], DataArray)
@test isa(df[:c], DataArray)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

source_tt_non_nullable =@Table(a=[1,2,3], b=[1.,2.,3.], c=["A","B","C"])
df_non_nullable = DataFrame(source_tt_non_nullable)

@test size(df_non_nullable) == (3,3)
@test isa(df_non_nullable[:a], Array)
@test isa(df_non_nullable[:b], Array)
@test isa(df_non_nullable[:c], Array)
@test df_non_nullable[:a] == [1,2,3]
@test df_non_nullable[:b] == [1.,2.,3.]
@test df_non_nullable[:c] == ["A","B","C"]

end
