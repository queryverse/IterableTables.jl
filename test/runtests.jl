using IterableTables
using NamedTuples
using SimpleTraits
using Base.Test

table_array = [@NT(a=1), @NT(a=2)]
other_array = [1,2,3]

@test istrait(IsIterableTable{typeof(table_array)})
@test !istrait(IsIterableTable{typeof(other_array)})
