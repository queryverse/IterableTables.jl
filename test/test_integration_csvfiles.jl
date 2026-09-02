@testitem "CSVFiles" begin
    using CSVFiles
    using FileIO
    using Query
    using DataFrames
    using Dates
    using Temporal

    mktempdir() do dir
        # save a DataFrame, load it back through a Query into a DataFrame
        df = DataFrame(name=["John", "Sally", "Kirk"], age=[23.0, 42.0, 59.0], children=[3, 5, 2])
        path = joinpath(dir, "test.csv")
        save(path, df)

        df2 = load(path) |> DataFrame
        @test size(df2) == (3, 3)
        @test df2[!, :name] == df[!, :name]

        df3 = load(path) |> @filter(_.age > 30) |> @map({_.name, _.children}) |> DataFrame
        @test size(df3) == (2, 2)
        @test df3[!, :name] == ["Sally", "Kirk"]

        # a NamedTuple generator is a valid sink argument for save
        genpath = joinpath(dir, "gen.csv")
        save(genpath, (a=i, b=i^2) for i in 1:4)
        df4 = load(genpath) |> DataFrame
        @test size(df4) == (4, 2)
        @test df4[!, :b] == [1, 4, 9, 16]

        # Temporal.TS round trip via the IterableTables integration
        dates = collect(Date(1999, 1, 1):Day(1):Date(1999, 1, 3))
        ts = TS(collect(1:3), dates, [:value])
        tspath = joinpath(dir, "ts.csv")
        save(tspath, ts)
        ts2 = load(tspath) |> x -> TS(x, index_column=:Index)
        @test size(ts2) == (3, 1)
        @test ts2.index == dates
        @test ts2.values == reshape([1, 2, 3], 3, 1)
    end
end
