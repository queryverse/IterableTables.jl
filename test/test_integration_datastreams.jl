using IterableTables
using NamedTuples
using DataFrames
using DataStreams
using CSV
using SQLite
using Feather
using Base.Test

@testset "DataStreams" begin

csv_source = CSV.Source(joinpath(dirname(@__FILE__),"testdata.csv"))
df = DataFrame(csv_source)

@test size(df) == (3,3)
@test isa(df[:a], Vector{Union{Int,Missing}})
@test isa(df[:b], Vector{Union{Float64,Missing}})
@test isa(df[:c], Vector{Union{String,Missing}})
@test df[:a] == [1,2,3]
@test df[:b] == [1.,2.,3.]
@test df[:c] == ["A","B","C"]

feather_source = Feather.Source(joinpath(Pkg.dir("Feather"),"test", "data", "CO2.feather"))
df_feather = DataFrame(feather_source)

@test size(df_feather) == (84,5)
@test eltype(df_feather[:Plant]) <: String
@test eltype(df_feather[:Type]) <:String
@test eltype(df_feather[:Treatment]) <:String
@test eltype(df_feather[:conc]) <:Float64
@test eltype(df_feather[:uptake]) <:Float64
@test df_feather[1,:Plant] == "Qn1"
@test df_feather[1,:Type] == "Quebec"
@test df_feather[1,:Treatment] == "nonchilled"
@test df_feather[1,:conc] == 95.0
@test df_feather[1,:uptake] == 16.

sqlite_source = SQLite.Source(SQLite.DB(joinpath(Pkg.dir("SQLite"), "test", "Chinook_Sqlite.sqlite")), "SELECT * FROM Employee;")
df_sqlite = DataFrame(sqlite_source)
@test size(df_sqlite) == (8,15)
@test isa(df_sqlite[:EmployeeId], Vector{Union{Int64,Missing}})
@test df_sqlite[1, :EmployeeId] == 1

end
