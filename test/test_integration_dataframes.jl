using IterableTables
using IteratorInterfaceExtensions
using DataFrames
using DataValues
using Test

@testset "DataFrames" begin

source_df = DataFrame(a=Union{Int,Missing}[1,2,3], b=Union{Float64,Missing}[1.,2.,3.], c=Union{String,Missing}["A","B","C"])

@test IteratorInterfaceExtensions.isiterable(source_df) == true

as_array = collect(IteratorInterfaceExtensions.getiterator(source_df))

@test length(as_array) == 3
@test as_array == [(a=DataValue(1),b=DataValue(1.),c=DataValue("A")),
    (a=DataValue(2),b=DataValue(2.),c=DataValue("B")),
    (a=DataValue(3),b=DataValue(3.),c=DataValue("C"))]

data = []
push!(data, [1,2,3])
push!(data, [1.,2.,3.])
push!(data, ["A","B","C"])
source_df_non_nullable = DataFrame(data, [:a,:b,:c])

non_nullable_as_array = collect(IteratorInterfaceExtensions.getiterator(source_df_non_nullable))

@test length(non_nullable_as_array) == 3
@test as_array == [(a=1,b=1.,c="A"),(a=2,b=2.,c="B"),(a=3,b=3.,c="C")]

source_array_non_nullable = [(a=1,b=1.,c="A"), (a=2,b=2.,c="B"), (a=3,b=3.,c="C")]
df = DataFrame(source_array_non_nullable)

@test size(df) == (3,3)
@test isa(df[:a], Array)
@test isa(df[:b], Array)
@test isa(df[:c], Array)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

source_array = [(a=DataValue(1),b=DataValue(1.),c=DataValue("A")), (a=DataValue(2),b=DataValue(2.),c=DataValue("B")), (a=DataValue(3),b=DataValue(3.),c=DataValue("C"))]
df = DataFrame(source_array)

@test size(df) == (3,3)
@test isa(df[:a], Vector{Union{Int,Missing}})
@test isa(df[:b], Vector{Union{Float64,Missing}})
@test isa(df[:c], Vector{Union{String,Missing}})
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

end
