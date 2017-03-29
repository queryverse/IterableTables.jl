@require IndexedTables begin
using IndexedTables: IndexedTable

immutable IndexedTableIterator{T, S<:IndexedTable}
    source::S
end

@traitimpl IsIterable{IndexedTables.IndexedTable}
@traitimpl IsIterableTable{IndexedTables.IndexedTable}

function getiterator{S<:IndexedTable}(source::S)
    col_expressions = Array{Expr,1}()
    columns_tuple_type = Expr(:curly, :Tuple)

    if S.parameters[3]<:NamedTuples.NamedTuple
        for (i,fieldname) in enumerate(fieldnames(S.parameters[3]))
            col_type = S.parameters[2].parameters[i]
            push!(col_expressions, Expr(:(::), fieldname, col_type))
            push!(columns_tuple_type.args, col_type)
        end
    else
        error("The keys of the IndexedTable need to have names.")
    end

    if S.parameters[1]<:NamedTuples.NamedTuple
        for (i,fieldname) in enumerate(fieldnames(S.parameters[1]))
            col_type = S.parameters[1].parameters[i]
            push!(col_expressions, Expr(:(::), fieldname, col_type))
            push!(columns_tuple_type.args, col_type)
        end
    else
        error("The values of the IndexedTable need to have names.")
    end

    t_expr = NamedTuples.make_tuple(col_expressions)
    T = eval(NamedTuples, t_expr)

    e_df = IndexedTableIterator{T,S}(source)

    return e_df
end

Base.eltype{T,S<:IndexedTable}(iter::IndexedTableIterator{T,S}) = T

Base.eltype{T,S<:IndexedTable}(iter::Type{IndexedTableIterator{T,S}}) = T

function Base.start{T,S<:IndexedTable}(iter::IndexedTableIterator{T,S})
    return 1
end

@generated function Base.next{T,S<:IndexedTable}(iter::IndexedTableIterator{T,S}, state)
    constructor_call = Expr(:call, :($T))

    index_of_first_data_element = length(S.parameters[3].parameters) + 1
    for i in 1:length(T.parameters)
        if i<index_of_first_data_element
            push!(constructor_call.args, :( iter.source.index.columns[$i][row] ))
        else
            push!(constructor_call.args, :( iter.source.data[row][$(i-index_of_first_data_element+1)] ))
        end
    end

    quote
        row = state
        a = $constructor_call
        return a, state+1
    end    
end

function Base.done{T,S<:IndexedTable}(iter::IndexedTableIterator{T,S}, state)
    return state>length(iter.source)
end

end
