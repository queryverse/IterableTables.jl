using IterableTables
using NamedTuples
using SimpleTraits
using TimeSeries
using DataFrames
using NullableArrays
using Base.Test

@testset "TimeSeries" begin

dates  = collect(Date(1999,1,1):Date(1999,1,3))

source_ta1 = TimeArray(dates, collect(1:length(dates)))
df1 = DataFrame(source_ta1)
@test size(df1) == (3,2)
@test df1[:timestamp] == dates
@test df1[:value] == [1,2,3]

source_ta2 = TimeArray(dates, collect(1:length(dates)), ["a"])
df2 = DataFrame(source_ta2)
@test size(df2) == (3,2)
@test df2[:timestamp] == dates
@test df2[:a] == [1,2,3]

source_ta3 = TimeArray(dates, hcat(collect(1:length(dates)), collect(length(dates):-1:1)), ["a", "b"])
df3 = DataFrame(source_ta3)
@test size(df3) == (3,3)
@test df3[:timestamp] == dates
@test df3[:a] == [1,2,3]
@test df3[:b] == [3,2,1]

source_ta4 = TimeArray(dates, hcat(collect(1:length(dates)), collect(length(dates):-1:1)))
df4 = DataFrame(source_ta4)
@test size(df4) == (3,3)
@test df4[:timestamp] == dates
@test df4[:_1] == [1,2,3]
@test df4[:_2] == [3,2,1]

end
