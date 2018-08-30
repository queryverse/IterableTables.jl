# Source

IteratorInterfaceExtensions.isiterable(x::DataFrames.DataFrame) = true
TableTraits.isiterabletable(x::DataFrames.DataFrame) = true

function TableTraits.getiterator(df::DataFrames.DataFrame)
    return TableTraitsUtils.create_tableiterator(getfield(df, :columns), names(df))
end
