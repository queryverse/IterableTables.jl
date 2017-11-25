using IterableTables
using TableTraits
using NamedTuples
using IndexedTables
using DataFrames
using Base.Test

@testset "IndexedTables" begin

source_it = IndexedTable(Columns(a = [1,2,3], b = [1.,2.,3.]),
             Columns(c = ["A","B","C"], d = [true,false,true]))

@test isiterable(source_it) == true

it_iterator = getiterator(source_it)

@test eltype(typeof(it_iterator)) == @NT(a::Int, b::Float64, c::String, d::Bool)
@test length(it_iterator) == 3

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

source_array_non_nullable = [@NT(a=1,b=1.,c="A",d=:a), @NT(a=2,b=2.,c="B",d=:b), @NT(a=3,b=3.,c="C",d=:c)]
it = IndexedTable(source_array_non_nullable)

@test length(it) == 3
@test dimlabels(it) == [:a, :b, :c]
@test it[1,1.,"A"].d == :a
@test it[2,2.,"B"].d == :b
@test it[3,3.,"C"].d == :c

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
@test dimlabels(it) == [:c, :d]
@test it["A",:a].a == 1
@test it["A",:a].b == 1.
@test it["B",:b].a == 2
@test it["B",:b].b == 2.
@test it["C",:c].a == 3
@test it["C",:c].b == 3.

source_array = [@NT(a::Union{Int, Null}, b::Union{Float64, Null})(1,1.), @NT(a::Union{Int, Null}, b::Union{Float64, Null})(2,2.), @NT(a::Union{Int, Null}, b::Union{Float64, Null})(3,3.)]
it = IndexedTable(source_array)

@test length(it) == 3
@test dimlabels(it) == [:a]
@test it[1,].b == 1.
@test it[2,].b == 2.
@test it[3,].b == 3.

end
