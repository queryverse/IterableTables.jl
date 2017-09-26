@require ValuedTimes begin

import StaticArrays

isiterable(x::ValuedTimes.ValuedTime) = true

isiterabletable(x::ValuedTimes.ValuedTime) = true

function getiterator(df::ValuedTimes.ValuedTime)
    col_names = [Symbol(i) for i in df.colnames]

    cols = []
    push!(cols, df.timevals)
    for col in df.datacols
        push!(cols, col)
    end

    return create_tableiterator(cols, col_names)
end

function ValuedTimes.ValuedTime(source)
    isiterabletable(source) || error("Not an iterable table.")

    columns, col_names = _fillcols(source)

    res = ValuedTimes.ValuedTime(StaticArrays.SVector(columns[1]), (StaticArrays.SVector.(columns[2:end])...))
    res.colnames[:] = col_names
    return res
end

end
