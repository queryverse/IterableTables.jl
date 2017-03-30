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

end
