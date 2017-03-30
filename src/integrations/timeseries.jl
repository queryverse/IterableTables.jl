@require TimeSeries begin

immutable TimeArrayIterator{T, S}
    source::S
end

@traitimpl IsIterable{TimeSeries.TimeArray}
@traitimpl IsIterableTable{TimeSeries.TimeArray}

function getiterator{S<:TimeSeries.TimeArray}(ta::S)
    col_expressions = Array{Expr,1}()
    df_columns_tuple_type = Expr(:curly, :Tuple)

    # Add column for timestamp
    push!(col_expressions, Expr(:(::), :timestamp, S.parameters[3]))
    push!(df_columns_tuple_type.args, S.parameters[3])

    etype = eltype(ta.values)
    if ndims(ta.values)==1
        push!(col_expressions, Expr(:(::), ta.colnames[1]=="" ? :value : Symbol(ta.colnames[1]), etype))
        push!(df_columns_tuple_type.args, etype)
    else
        for i in 1:size(ta.values,2)
            push!(col_expressions, Expr(:(::), Symbol(ta.colnames[i]), etype))
            push!(df_columns_tuple_type.args, etype)
        end
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(IterableTables.TimeArrayIterator{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = S

    eval(NamedTuples, :(import IterableTables))
    t = eval(NamedTuples, t2)

    e_ta = t(ta)

    return e_ta
end

function Base.length{T,TS}(iter::TimeArrayIterator{T,TS})
    return size(iter.source,1)
end

function Base.eltype{T,TS}(iter::TimeArrayIterator{T,TS})
    return T
end

function Base.start{T,TS}(iter::TimeArrayIterator{T,TS})
    return 1
end

@generated function Base.next{T,S}(iter::TimeArrayIterator{T,S}, state)
    constructor_call = Expr(:call, :($T))

    # Add timestamp column
    push!(constructor_call.args, :(iter.source.timestamp[i]))

    for i in 1:length(T.parameters)-1
        push!(constructor_call.args, :(iter.source.values[i,$i]))
    end

    quote
        i = state
        a = $constructor_call
        return a, state+1
    end
end

function Base.done{T,TS}(iter::TimeArrayIterator{T,TS}, state)
    return state>length(iter.source.timestamp)
end

# Sink

@traitfn function TimeSeries.TimeArray{X; IsIterableTable{X}}(x::X, timestamp_column::Symbol=:timestamp)
    if column_count(x)<2
        error("Need at least two columns")
    end

    names = column_names(x)
    
    if !(timestamp_column in names)
        error("No timestamp column found.")
    end

    data_columns = filter(i->i[1]!=timestamp_column, enumerate(zip(names, column_types(x))))

    data_type = data_columns[1][2][2]

    if any(i->i[2][2]!=data_type, data_columns)
        error("All data columns need to be of the same type.")
    end

end

end
