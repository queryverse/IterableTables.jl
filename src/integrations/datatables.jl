@require DataTables begin
using NullableArrays
using DataValues

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
        if isa(df.columns[i], NullableArray)
            push!(col_expressions, Expr(:(::), names(df)[i], DataValue{etype.parameters[1]}))
        else
            push!(col_expressions, Expr(:(::), names(df)[i], etype))
        end
        push!(df_columns_tuple_type.args, typeof(df.columns[i]))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

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

function Base.done{T,TS}(iter::DataTableIterator{T,TS}, state)
    return state>length(iter.columns[1])
end

# Sink

@generated function _filldt_without_length(columns, enumerable)
    n = length(columns.types)
    push_exprs = Expr(:block)
    for i in 1:n
        if columns.parameters[i] <: NullableArray
            ex = :( push!(columns[$i], Nullable(i[$i]) ))
        else
            ex = :( push!(columns[$i], i[$i]) )
        end
        push!(push_exprs.args, ex)        
    end

    quote
        for i in enumerable
            $push_exprs
        end
    end
end

@generated function _filldt_with_length(columns, enumerable, state)    
    n = length(columns.types)
    push_exprs = Expr(:block)
    for col_idx in 1:n
        if columns.parameters[col_idx] <: NullableArray
            ex = :( columns[$col_idx][i] = Nullable(v[$col_idx] ))
        else
            ex = :( columns[$col_idx][i] = v[$col_idx] )
        end
        push!(push_exprs.args, ex)
    end

    quote
        state_internal = state
        i = 1
        while !done(enumerable, state_internal)
            res = next(enumerable, state_internal)
            v = res[1]
            state_internal = res[2]
            $push_exprs
            i += 1
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
    if iteratorsize2(iter) in (Base.HasLength(), HasLengthAfterStart())
        state = start(iter)

        rows = iteratorsize2(iter)==HasLengthAfterStart() ? length(iter, state) : length(iter)

        for t in column_types
            if isa(t, TypeVar)
                push!(columns, Array{Any}(rows))
            elseif t <: DataValue
                push!(columns, NullableArray(t.parameters[1],rows))
            else
                push!(columns, Array{t}(rows))
            end
        end  
        _filldt_with_length((columns...), iter, state)      
    else
        for t in column_types
            if isa(t, TypeVar)
                push!(columns, Array{Any}(0))
            elseif t <: DataValue
                push!(columns, NullableArray(t.parameters[1],0))
            else
                push!(columns, Array{t}(0))
            end
        end

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
