using IterableTables
using DataFrames
using DiffEqBase
using OrdinaryDiffEq
using Base.Test

@testset "DifferentialEquations" begin

f_1dlinear = (t,u) -> 1.01u
prob = ODEProblem(f_1dlinear,rand(),(0.0,1.0))
sol =solve(prob,Euler();dt=1//2^(4))
df = DataFrame(sol)

@test size(df) == (17,2)
@test length(df[:timestamp]) == 17
@test length(df[:value]) == 17

f_2dlinear = (t,u,du) -> du.=1.01u
prob = ODEProblem(f_2dlinear,rand(2),(0.0,1.0))
sol =solve(prob,Euler();dt=1//2^(4))
df = DataFrame(sol)

@test size(df) == (17,3)
@test length(df[:timestamp]) == 17
@test length(df[:value1]) == 17
@test length(df[:value2]) == 17

prob = ODEProblem(f_2dlinear_named,[1.0,1.0],(0.0,1.0))
sol =solve(prob,Tsit5())
df = DataFrame(sol)

@test size(df) == (7,3)
@test length(df[:timestamp]) == 7
@test length(df[:x]) == 7
@test length(df[:y]) == 7

end
