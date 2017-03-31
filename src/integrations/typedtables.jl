@require TypedTables begin

import NullableArrays

immutable TypedTableIterator{T, TS}
    df::TypedTables.Table
    # This field hols a tuple with the columns of the DataFrame.
    # Having a tuple of the columns here allows the iterator
    # functions to access the columns in a type stable way.
    columns::TS
end

@traitimpl IsIterable{TypedTables.Table}
@traitimpl IsIterableTable{TypedTables.Table}

function getiterator(df::TypedTables.Table)
    col_expressions = Array{Expr,1}()
    df_columns_tuple_type = Expr(:curly, :Tuple)
    for i in 1:length(df.data)
        etype = eltype(df.data[i])
        push!(col_expressions, Expr(:(::), names(df)[i], etype))
        push!(df_columns_tuple_type.args, typeof(df.data[i]))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(IterableTables.TypedTableIterator{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = df_columns_tuple_type

    eval(NamedTuples, :(import IterableTables))
    t = eval(NamedTuples, t2)

    e_df = t(df, df.data)

    return e_df
end

function Base.length{T,TS}(iter::TypedTableIterator{T,TS})
    return size(iter.df,1)
end

function Base.eltype{T,TS}(iter::TypedTableIterator{T,TS})
    return T
end

function Base.start{T,TS}(iter::TypedTableIterator{T,TS})
    return 1
end

@generated function Base.next{T,TS}(iter::TypedTableIterator{T,TS}, state)
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

function Base.done{T,TS}(iter::TypedTableIterator{T,TS}, state)
    return state>size(iter.df,1)
end

# Sink

@generated function _filltt(source, tt)
    n = length(tt.parameters[2].parameters)
    push_exprs = Expr(:block)
    for i in 1:n
        ex = :( push!(tt.data[$i], row[$i]) )
        push!(push_exprs.args, ex)
    end

    quote
        for row in source
            $push_exprs
        end
    end
end

@traitfn function TypedTables.Table{X; IsIterableTable{X}}(x::X)
    iter = getiterator(x)

    source_colnames = IterableTables.column_names(iter)
    source_coltypes = IterableTables.column_types(iter)

    columns = []
    for t in source_coltypes
        if t <: Nullable
            push!(columns, NullableArrays.NullableArray(t.parameters[1],0))
        else
            push!(columns, Array{t}(0))
        end
    end

    T = eval(TypedTables, 
        Expr(:curly, :Table, Expr(:tuple, [QuoteNode(i) for i in source_colnames]...), Expr(:curly, :Tuple, [typeof(i) for i in columns]...))
    )

    tt = T()

    _filltt(iter, tt)    

    return tt
end

end
