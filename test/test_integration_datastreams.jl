using IterableTables
using NamedTuples
using SimpleTraits
using DataFrames
using DataStreams
using CSV
using SQLite
using NullableArrays
using Base.Test
if VERSION < v"0.6.0-"
    using Feather
end

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

if VERSION < v"0.6.0-"
    feather_source = Feather.Source(joinpath(Pkg.dir("Feather"),"test", "newdata", "CO2.feather"))
    df_feather = DataFrame(feather_source)

    @test size(df_feather) == (84,5)
    @test isa(df_feather[:Plant], DataArray)
    @test isa(df_feather[:Type], DataArray)
    @test isa(df_feather[:Treatment], DataArray)
    @test isa(df_feather[:conc], DataArray)
    @test isa(df_feather[:uptake], DataArray)
    @test df_feather[1,:Plant] == "Qn1"
    @test df_feather[1,:Type] == "Quebec"
    @test df_feather[1,:Treatment] == "nonchilled"
    @test df_feather[1,:conc] == 95.0
    @test df_feather[1,:uptake] == 16.

    sqlite_source = SQLite.Source(SQLite.DB(joinpath(Pkg.dir("SQLite"), "test", "Chinook_Sqlite.sqlite")), "SELECT * FROM Employee;")
    df_sqlite = DataFrame(sqlite_source)
    @test size(df_sqlite) == (8,15)
    @test isa(df_sqlite[:EmployeeId], DataArray)
    @test df_sqlite[1, :EmployeeId] == 1
end

end
