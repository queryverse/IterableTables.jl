using DataValues

# T is the type of the elements produced
# TS is a tuple type that stores the columns of the table
immutable TableIterator{T, TS}
    columns::TS
end

function create_tableiterator(columns, names::Vector{Symbol})
    col_expressions = Array{Expr,1}()
    df_columns_tuple_type = Expr(:curly, :Tuple)
    for i in 1:length(columns)
        etype = eltype(columns[i])
        if etype <: Nullable
            push!(col_expressions, Expr(:(::), names[i], DataValue{etype.parameters[1]}))
        else
            push!(col_expressions, Expr(:(::), names[i], etype))
        end
        push!(df_columns_tuple_type.args, typeof(columns[i]))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(TableIterator{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = df_columns_tuple_type

    t = eval(t2)

    e_df = t((columns...))

    return e_df
end

function Base.length{T,TS}(iter::TableIterator{T,TS})
    return length(iter.columns[1])
end

function Base.eltype{T,TS}(iter::TableIterator{T,TS})
    return T
end

function Base.start{T,TS}(iter::TableIterator{T,TS})
    return 1
end

@generated function Base.next{T,TS}(iter::TableIterator{T,TS}, state)
    constructor_call = Expr(:call, :($T))
    for (i,t) in enumerate(T.parameters)
        if iter.parameters[1].parameters[i] <: DataValue
            push!(constructor_call.args, :(DataValue(columns[$i][i])))
        else
            push!(constructor_call.args, :(columns[$i][i]))
        end
    end

    quote
        i = state
        columns = iter.columns
        a = $constructor_call
        return a, state+1
    end
end

function Base.done{T,TS}(iter::TableIterator{T,TS}, state)
    return state>length(iter.columns[1])
end

# Sink

@generated function _fill_cols_without_length(columns, enumerable)
    n = length(columns.types)
    push_exprs = Expr(:block)
    for i in 1:n
        ex = :( push!(columns[$i], i[$i]) )
        push!(push_exprs.args, ex)        
    end

    quote
        for i in enumerable
            $push_exprs
        end
    end
end

@generated function _fill_cols_with_length(columns, enumerable)
    n = length(columns.types)
    push_exprs = Expr(:block)
    for col_idx in 1:n
        ex = :( columns[$col_idx][i] = v[$col_idx] )
        push!(push_exprs.args, ex)
    end

    quote
        for (i,v) in enumerate(enumerable)
            $push_exprs
        end
    end
end

function _fillcols(x)
    iter = getiterator(x)
    
    T = eltype(iter)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterator.")
    end

    column_types = IterableTables.column_types(iter)
    column_names = IterableTables.column_names(iter)

    rows = Base.iteratorsize(typeof(iter))==Base.HasLength() ? length(iter) : 0

    columns = []
    for t in column_types
        if isa(t, TypeVar)
            push!(columns, Array{Any}(rows))
        else
            push!(columns, Array{t}(rows))
        end
    end

    if Base.iteratorsize(typeof(iter))==Base.HasLength()
        _fill_cols_with_length((columns...), iter)
    else
        _fill_cols_without_length((columns...), iter)
    end

    return columns, column_names
end
