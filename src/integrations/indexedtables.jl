@require IndexedTables begin
using IndexedTables: IndexedTable

immutable IndexedTableIterator{T, S<:IndexedTable}
    source::S
end

isiterable(x::IndexedTables.IndexedTable) = true
isiterabletable(x::IndexedTables.IndexedTable) = true

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
    T = eval(t_expr)

    e_df = IndexedTableIterator{T,S}(source)

    return e_df
end

Base.eltype{T,S<:IndexedTable}(iter::IndexedTableIterator{T,S}) = T

Base.eltype{T,S<:IndexedTable}(iter::Type{IndexedTableIterator{T,S}}) = T

function Base.length{T,S<:IndexedTable}(iter::IndexedTableIterator{T,S})
    return length(iter.source)
end

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

# Sink

@generated function _fillIndexedTable{idx_indices,data_indices}(iter,idx_storage,data_storage,::Type{idx_indices},::Type{data_indices})
    push_exprs = Expr(:block)
    for (i,idx) in enumerate(map(i->i.parameters[1],idx_indices.parameters))
        ex = :( push!(idx_storage.columns[$i], row[$idx]) )
        push!(push_exprs.args, ex)
    end

    for (i,idx) in enumerate(map(i->i.parameters[1],data_indices.parameters))
        ex = :( push!(data_storage.columns[$i], row[$idx]) )
        push!(push_exprs.args, ex)
    end
    
    quote
        for row in iter
            $push_exprs
        end
    end
end

function IndexedTables.IndexedTable(x; idxcols::Union{Void,Vector{Symbol}}=nothing, datacols::Union{Void,Vector{Symbol}}=nothing)
    isiterabletable(x) || error()
    iter = getiterator(x)

    source_colnames = IterableTables.column_names(iter)
    source_coltypes = IterableTables.column_types(iter)

    if idxcols==nothing && datacols==nothing
        idxcols = source_colnames[1:end-1]
        datacols = [source_colnames[end]]
    elseif idxcols==nothing
        idxcols = setdiff(source_colnames,datacols)
    elseif datacols==nothing
        datacols = setdiff(source_colnames, idxcols)
    end

    if length(setdiff(idxcols, source_colnames))>0
        error("Unknown idxcol")
    end

    if length(setdiff(datacols, source_colnames))>0
        error("Unknown datacol")
    end

    idxcols_indices = [findfirst(source_colnames,i) for i in idxcols]
    datacols_indices = [findfirst(source_colnames,i) for i in datacols]

    idx_storage = IndexedTables.Columns([Array{source_coltypes[i],1}(0) for i in idxcols_indices]..., names=[source_colnames[i] for i in idxcols_indices])
    data_storage = IndexedTables.Columns([Array{source_coltypes[i],1}(0) for i in datacols_indices]..., names=[source_colnames[i] for i in datacols_indices])

    tuple_type_idx = eval(Expr(:curly, :Tuple, [Expr(:curly, :Val, i) for i in idxcols_indices]...))
    tuple_type_data = eval(Expr(:curly, :Tuple, [Expr(:curly, :Val, i) for i in datacols_indices]...))

    _fillIndexedTable(iter, idx_storage, data_storage, tuple_type_idx, tuple_type_data)

    return IndexedTables.IndexedTable(idx_storage, data_storage)
end

end
