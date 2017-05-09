using IterableTables
using NamedTuples
using TypedTables
using DataFrames
using NullableArrays
using Base.Test

@testset "TypedTables" begin

source_tt = @Table(a=Nullable{Int}[1,2,3], b=Nullable{Float64}[1.,2.,3.], c=Nullable{String}["A","B","C"])

@test isiterable(source_tt) == true

tt_iterator = getiterator(source_tt)

@test length(tt_iterator) == 3

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

source_array_non_nullable = [@NT(a=1,b=1.,c="A"), @NT(a=2,b=2.,c="B"), @NT(a=3,b=3.,c="C")]
tt = Table(source_array_non_nullable)

@test TypedTables.ncol(tt) == 3
@test TypedTables.nrow(tt) == 3
@test isa(@col(tt, a), Array)
@test isa(@col(tt, b), Array)
@test isa(@col(tt, c), Array)
@test @col(tt, a) == [1,2,3]
@test @col(tt, b) == [1.,2.,3.]
@test @col(tt, c) == ["A","B","C"]

source_array = [@NT(a=Nullable(1),b=Nullable(1.),c=Nullable("A")), @NT(a=Nullable(2),b=Nullable(2.),c=Nullable("B")), @NT(a=Nullable(3),b=Nullable(3.),c=Nullable("C"))]
tt = Table(source_array)

@test TypedTables.ncol(tt) == 3
@test TypedTables.nrow(tt) == 3
@test isa(@col(tt, a), NullableArray)
@test isa(@col(tt, b), NullableArray)
@test isa(@col(tt, c), NullableArray)
@test all(i->get(i), @col(tt, a) .== NullableArray([1,2,3], [false, false, false]))
@test all(i->get(i), @col(tt, b) .== NullableArray([1.,2.,3.], [false, false, false]))
@test all(i->get(i), @col(tt, c) .== NullableArray(["A","B","C"], [false, false, false]))

end
