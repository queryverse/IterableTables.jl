@require TypedTables begin
using TableTraits
using DataValues
using NullableArrays

immutable TypedTableIterator{T, TS}
    df::TypedTables.Table
    # This field hols a tuple with the columns of the DataFrame.
    # Having a tuple of the columns here allows the iterator
    # functions to access the columns in a type stable way.
    columns::TS
end

TableTraits.isiterable(x::TypedTables.Table) = true
TableTraits.isiterabletable(x::TypedTables.Table) = true

function TableTraits.getiterator(df::TypedTables.Table)
    col_expressions = Array{Expr,1}()
    df_columns_tuple_type = Expr(:curly, :Tuple)
    for i in 1:length(df.data)
        etype = eltype(df.data[i])
        if isa(df.data[i], NullableArray)
            push!(col_expressions, Expr(:(::), names(df)[i], DataValue{etype.parameters[1]}))
        else            
            push!(col_expressions, Expr(:(::), names(df)[i], etype))
        end
        push!(df_columns_tuple_type.args, typeof(df.data[i]))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(TypedTableIterator{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = df_columns_tuple_type

    t = eval(t2)

    e_df = t(df, df.data)

    return e_df
end

function Base.length{T,TS}(iter::TypedTableIterator{T,TS})
    return size(iter.df,1)
end

function Base.eltype{T,TS}(iter::TypedTableIterator{T,TS})
    return T
end

Base.eltype(::Type{TypedTableIterator{T,TS}}) where {T,TS} = T

function Base.start{T,TS}(iter::TypedTableIterator{T,TS})
    return 1
end

@generated function Base.next{T,TS}(iter::TypedTableIterator{T,TS}, state)
    constructor_call = Expr(:call, :($T))
    args = []
    for (i,t) in enumerate(T.parameters)
        if iter.parameters[1].parameters[i] <: DataValue
            push!(args, :(DataValue(columns[$i][i])))
        else        
            push!(args, :(columns[$i][i]))
        end
    end
    push!(constructor_call.args, Expr(:tuple, args...))

    quote
        i = state
        columns = iter.columns
        a = $constructor_call
        return a, state+1
    end
end

function Base.done{T,TS}(iter::TypedTableIterator{T,TS}, state)
    return state>size(iter.df,1)
end

# Sink

@generated function _filltt(source, tt)
    n = length(tt.parameters[2].parameters)
    push_exprs = Expr(:block)
    for i in 1:n
        if tt.parameters[2].parameters[i] <: NullableArray
            ex = :( push!(tt.data[$i], Nullable(row[$i]) ))
        else 
            ex = :( push!(tt.data[$i], row[$i]) )
        end
        push!(push_exprs.args, ex)
    end

    quote
        for row in source
            $push_exprs
        end
    end
end

function TypedTables.Table(x)
    if isiterabletable(x)
    
        iter = getiterator(x)

        source_colnames = TableTraits.column_names(iter)
        source_coltypes = TableTraits.column_types(iter)

        columns = []
        for t in source_coltypes
            if t <: DataValue
                push!(columns, NullableArrays.NullableArray(t.parameters[1],0))
            else
                push!(columns, Array{t}(0))
            end
        end

        T = eval(Expr(:curly, :(TypedTables.Table), Expr(:tuple, [QuoteNode(i) for i in source_colnames]...), Expr(:curly, :Tuple, [typeof(i) for i in columns]...)))

        tt = T()

        _filltt(iter, tt)    

        return tt
    else
        return convert(TypedTables.Table, x)
    end
end

end
