using IterableTables
using StatsModels
using GLM
using DataValues
using Test

@testset "StatsModels" begin

source_array = [(a=1,b=1.,c="A"), (a=2,b=2.,c="B"), (a=3,b=3.,c="C")]

mf_array = StatsModels.ModelFrame(StatsModels.@formula(a~b), source_array)

@test mf_array isa StatsModels.ModelFrame

x = lm(StatsModels.@formula(a~b), source_array)

end
