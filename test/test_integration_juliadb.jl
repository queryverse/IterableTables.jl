using IterableTables
using NamedTuples
using JuliaDB
using DataFrames
using NullableArrays
using Base.Test

@testset "JuliaDB" begin

source_df = DataFrame(a=[1,2,3], b=[4.,5.,6.])

jdb = distribute(source_df)

@test isa(jdb, JuliaDB.DTable)

target_df = DataFrame(jdb)

@test source_df == target_df

end
