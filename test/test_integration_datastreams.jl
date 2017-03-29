using IterableTables
using NamedTuples
using SimpleTraits
using DataFrames
using DataStreams
using CSV
using NullableArrays
using Base.Test

@testset "DataStreams" begin

csv_source = CSV.Source(joinpath(dirname(@__FILE__),"testdata.csv"))
df = DataFrame(csv_source)

@test size(df) == (3,3)
@test isa(df[:a], DataArray)
@test isa(df[:b], DataArray)
@test isa(df[:c], DataArray)
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

end
