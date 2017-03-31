using IterableTables
using NamedTuples
using SimpleTraits
using PooledArrays
using IndexedTables
using DataFrames
using NullableArrays
using Base.Test

@testset "IndexedTables" begin

source_it = IndexedTable(Columns(a = [1,2,3], b = [1.,2.,3.]),
             Columns(c = ["A","B","C"], d = [true,false,true]))

df = DataFrame(source_it)

@test size(df) == (3,4)
@test isa(df[:a], Array)
@test isa(df[:b], Array)
@test isa(df[:c], Array)
@test isa(df[:d], Array)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]
@test df[:d] == [true,false,true]

source_array_non_nullable = [@NT(a=1,b=1.,c="A"), @NT(a=2,b=2.,c="B"), @NT(a=3,b=3.,c="C")]
it = IndexedTable(source_array_non_nullable)

@test length(it) == 3
@test dimlabels(it) == [:a, :b]
@test it[1,1.].c == "A"
@test it[2,2.].c == "B"
@test it[3,3.].c == "C"

it = IndexedTable(source_array_non_nullable, idxcols=[:c])

@test length(it) == 3
@test dimlabels(it) == [:c]
@test it["A"].a == 1
@test it["A"].b == 1.
@test it["B"].a == 2
@test it["B"].b == 2.
@test it["C"].a == 3
@test it["C"].b == 3.

it = IndexedTable(source_array_non_nullable, datacols=[:a, :b])

@test length(it) == 3
@test dimlabels(it) == [:c]
@test it["A"].a == 1
@test it["A"].b == 1.
@test it["B"].a == 2
@test it["B"].b == 2.
@test it["C"].a == 3
@test it["C"].b == 3.

source_array = [@NT(a=Nullable(1),b=Nullable(1.),c=Nullable("A")), @NT(a=Nullable(2),b=Nullable(2.),c=Nullable("B")), @NT(a=Nullable(3),b=Nullable(3.),c=Nullable("C"))]
it = IndexedTable(source_array)

@test length(it) == 3
@test dimlabels(it) == [:a, :b]
@test get(it[Nullable(1),Nullable(1.)].c == Nullable("A"))
@test get(it[Nullable(2),Nullable(2.)].c == Nullable("B"))
@test get(it[Nullable(3),Nullable(3.)].c == Nullable("C"))

end
