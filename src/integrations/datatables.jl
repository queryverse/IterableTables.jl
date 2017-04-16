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

    t2 = :(IterableTables.DataTableIterator{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = df_columns_tuple_type

    eval(NamedTuples, :(import IterableTables))
    t = eval(NamedTuples, t2)

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

@generated function _filldt(columns, enumerable)
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

function _DataTable(x)
    iter = getiterator(x)
    
    T = eltype(iter)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterator into a DataTable.")
    end

    column_types = IterableTables.column_types(iter)
    column_names = IterableTables.column_names(iter)

    columns = []
    for t in column_types
        if isa(t, TypeVar)
            push!(columns, Array{Any}(0))
        elseif t <: Nullable
            push!(columns, NullableArray(t.parameters[1],0))
        else
            push!(columns, Array{t}(0))
        end
    end
    df = DataTables.DataTable(columns, column_names)
    _filldt((df.columns...), iter)
    return df
end

DataTables.DataTable{T<:NamedTuple}(x::Array{T,1}) = _DataTable(x)

function DataTables.DataTable(x)
    isiterabletable(x) || error()
    return _DataTable(x)
end

end
