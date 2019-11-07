using IterableTables
using TimeSeries
using DataFrames
using TableTraits
using IteratorInterfaceExtensions
using Test

@testset "TimeSeries" begin

dates  = collect(Date(1999,1,1):Day(1):Date(1999,1,3))

source_ta1 = TimeArray(dates, collect(1:length(dates)))

@test IteratorInterfaceExtensions.isiterable(source_ta1) == true

source_it = IteratorInterfaceExtensions.getiterator(source_ta1)

@test length(source_it) == 3

df1 = DataFrame(source_ta1)
@test size(df1) == (3,2)
@test df1[:timestamp] == dates
@test df1[:A] == [1,2,3]

source_ta2 = TimeArray(dates, collect(1:length(dates)), [:a])
df2 = DataFrame(source_ta2)
@test size(df2) == (3,2)
@test df2[:timestamp] == dates
@test df2[:a] == [1,2,3]

source_ta3 = TimeArray(dates, hcat(collect(1:length(dates)), collect(length(dates):-1:1)), [:a, :b])
df3 = DataFrame(source_ta3)
@test size(df3) == (3,3)
@test df3[:timestamp] == dates
@test df3[:a] == [1,2,3]
@test df3[:b] == [3,2,1]

source_ta4 = TimeArray(dates, hcat(collect(1:length(dates)), collect(length(dates):-1:1)))
df4 = DataFrame(source_ta4)
@test size(df4) == (3,3)
@test df4[:timestamp] == dates
@test df4[:A] == [1,2,3]
@test df4[:B] == [3,2,1]

source_df = DataFrame(a=[4.,5.], timestamp=[Date(1999,1,1),Date(1999,1,2)], b=[6.,8.])
ta2 = TimeArray(source_df, timestamp=:timestamp)
@test length(ta2) == 2
@test TimeSeries.colnames(ta2) == [:a, :b]
@test TimeSeries.values(ta2) == [4. 6.;5. 8.]
@test TimeSeries.timestamp(ta2) == [Date(1999,1,1),Date(1999,1,2)]

end
