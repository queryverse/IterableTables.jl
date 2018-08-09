# Source

IteratorInterfaceExtensions.isiterable(x::DataFrames.DataFrame) = true
TableTraits.isiterabletable(x::DataFrames.DataFrame) = true

function TableTraits.getiterator(df::DataFrames.DataFrame)
    return TableTraitsUtils.create_tableiterator(getfield(df, :columns), names(df))
end

# # Sink

function _DataFrame(x)
    cols, names = create_columns_from_iterabletable(x, na_representation=:missing)

    return DataFrames.DataFrame(cols, names)
end

DataFrames.DataFrame(x::AbstractVector{T}) where {T<:NamedTuple} = _DataFrame(x)

function DataFrames.DataFrame(x)
    if TableTraits.isiterabletable(x)
        return _DataFrame(x)
    else
        return convert(DataFrames.DataFrame, x)
    end
end
