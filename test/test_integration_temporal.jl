using IterableTables
using NamedTuples
using Temporal
using DataFrames
using NullableArrays
import TypedTables
using Base.Test

@testset "Temporal" begin

dates  = collect(Date(1999,1,1):Date(1999,1,3))

source_ta1 = TS(collect(1:length(dates)), dates, [:value])

@test isiterable(source_ta1) == true

source_it = getiterator(source_ta1)

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

source_tt = TypedTables.@Table(a=[4.,5.], time=[Date(1999,1,1),Date(1999,1,2)], b=[6.,8.], c=[12.,24.])
ta1 = TS(source_tt, index_column=:time)
@test size(ta1) == (2,3)
@test ta1.values == [4. 6. 12.;5. 8. 24]
@test ta1.index == [Date(1999,1,1),Date(1999,1,2)]

source_df = DataFrame(a=[4.,5.], Index=[Date(1999,1,1),Date(1999,1,2)], b=[6.,8.])
ta2 = TS(source_df)
@test size(ta2) == (2,2)
@test ta2.values == [4. 6.;5. 8.]
@test ta2.index == [Date(1999,1,1),Date(1999,1,2)]

end
