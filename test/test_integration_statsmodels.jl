using IterableTables
using NamedTuples
using StatsModels
using DataFrames
using Base.Test

@testset "StatsModels" begin

source_array = [@NT(a=Nullable(1),b=Nullable(1.),c=Nullable("A")), @NT(a=Nullable(2),b=Nullable(2.),c=Nullable("B")), @NT(a=Nullable(3),b=Nullable(3.),c=Nullable("C"))]
source_df = DataFrame(a=[1,2,3], b=[1.,2.,3.], c=["A","B","C"])

# TODO add some test beyond just creating a ModelFrame
mf_array = StatsModels.ModelFrame(StatsModels.@formula(a~b), source_array)
mf_dt = StatsModels.ModelFrame(StatsModels.@formula(a~b), source_df)

end
