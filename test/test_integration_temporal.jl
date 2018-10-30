using IterableTables
using IteratorInterfaceExtensions
using TableTraits
using Temporal
using DataFrames
using Test

@testset "Temporal" begin

dates  = collect(Date(1999,1,1):Day(1):Date(1999,1,3))

source_ta1 = TS(collect(1:length(dates)), dates, [:value])

@test IteratorInterfaceExtensions.isiterable(source_ta1) == true

source_it = IteratorInterfaceExtensions.getiterator(source_ta1)

@test length(source_it) == 3

df1 = DataFrame(source_ta1)
@test size(df1) == (3,2)
@test df1[:Index] == dates
@test df1[:value] == [1,2,3]

source_ta2 = TS(collect(1:length(dates)), dates, :a)
df2 = DataFrame(source_ta2)
@test size(df2) == (3,2)
@test df2[:Index] == dates
@test df2[:a] == [1,2,3]

source_ta3 = TS(hcat(collect(1:length(dates)), collect(length(dates):-1:1)), dates, [:a, :b])
df3 = DataFrame(source_ta3)
@test size(df3) == (3,3)
@test df3[:Index] == dates
@test df3[:a] == [1,2,3]
@test df3[:b] == [3,2,1]

source_ta4 = TS(hcat(collect(1:length(dates)), collect(length(dates):-1:1)), dates, [:a, :b])
df4 = DataFrame(source_ta4)
@test size(df4) == (3,3)
@test df4[:Index] == dates
@test df4[:a] == [1,2,3]
@test df4[:b] == [3,2,1]

source_df = DataFrame(a=[4.,5.], Index=[Date(1999,1,1),Date(1999,1,2)], b=[6.,8.])
ta2 = TS(source_df)
@test size(ta2) == (2,2)
@test ta2.values == [4. 6.;5. 8.]
@test ta2.index == [Date(1999,1,1),Date(1999,1,2)]

end
