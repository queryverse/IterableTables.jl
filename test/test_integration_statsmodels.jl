using IterableTables
using StatsModels
using GLM
using DataValues
using Test

@testset "StatsModels" begin

source_array = [(a=DataValue(1),b=DataValue(1.),c=DataValue("A")), (a=DataValue(2),b=DataValue(2.),c=DataValue("B")), (a=DataValue(3),b=DataValue(3.),c=DataValue("C"))]

# TODO add some test beyond just creating a ModelFrame
mf_array = StatsModels.ModelFrame(StatsModels.@formula(a~b), source_array)

# lm(StatsModels.@formula(a~b), source_df)

end
