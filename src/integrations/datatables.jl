@require DataTables begin
using NullableArrays

# T is the type of the elements produced
# TS is a tuple type that stores the columns of the DataTable
immutable DataTableIterator{T, TS}
    df::DataTables.DataTable
    # This field hols a tuple with the columns of the DataTable.
    # Having a tuple of the columns here allows the iterator
    # functions to access the columns in a type stable way.
    columns::TS
end

isiterable(x::DataTables.DataTable) = true
isiterabletable(x::DataTables.DataTable) = true

function getiterator(df::DataTables.DataTable)
    col_expressions = Array{Expr,1}()
    df_columns_tuple_type = Expr(:curly, :Tuple)
    for i in 1:length(df.columns)
        etype = eltype(df.columns[i])
        push!(col_expressions, Expr(:(::), names(df)[i], etype))
        push!(df_columns_tuple_type.args, typeof(df.columns[i]))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)
    t_expr.args[1] = Expr(:., :NamedTuples, QuoteNode(t_expr.args[1]))

    t2 = :(DataTableIterator{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = df_columns_tuple_type

    t = eval(t2)

    e_df = t(df, (df.columns...))

    return e_df
end

function Base.length{T,TS}(iter::DataTableIterator{T,TS})
    return size(iter.df,1)
end

function Base.eltype{T,TS}(iter::DataTableIterator{T,TS})
    return T
end

function Base.start{T,TS}(iter::DataTableIterator{T,TS})
    return 1
end

@generated function Base.next{T,TS}(iter::DataTableIterator{T,TS}, state)
    constructor_call = Expr(:call, :($T))
    for (i,t) in enumerate(T.parameters)
        push!(constructor_call.args, :(columns[$i][i]))
    end

    quote
        i = state
        columns = iter.columns
        a = $constructor_call
        return a, state+1
    end
end

function Base.done{T,TS}(iter::DataTableIterator{T,TS}, state)
    return state>size(iter.df,1)
end

# Sink

@generated function _filldt_without_length(columns, enumerable)
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

@generated function _filldt_with_length(columns, enumerable)
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

function _DataTable(x)
    iter = getiterator(x)
    
    T = eltype(iter)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterator into a DataTable.")
    end

    column_types = IterableTables.column_types(iter)
    column_names = IterableTables.column_names(iter)

    rows = Base.iteratorsize(typeof(iter))==Base.HasLength() ? length(iter) : 0

    columns = []
    for t in column_types
        if isa(t, TypeVar)
            push!(columns, Array{Any}(rows))
        elseif t <: Nullable
            push!(columns, NullableArray(t.parameters[1],rows))
        else
            push!(columns, Array{t}(rows))
        end
    end

    if Base.iteratorsize(typeof(iter))==Base.HasLength()
        _filldt_with_length((columns...), iter)
    else
        _filldt_without_length((columns...), iter)
    end

    dt = DataTables.DataTable(columns, column_names)
    return dt
end

DataTables.DataTable{T<:NamedTuple}(x::Array{T,1}) = _DataTable(x)

function DataTables.DataTable(x)
    isiterabletable(x) || error()
    return _DataTable(x)
end

end
