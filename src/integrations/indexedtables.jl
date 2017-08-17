@require IndexedTables begin
using TableTraits
using IndexedTables: IndexedTable
import NullableArrays

TableTraits.isiterable(x::IndexedTables.IndexedTable) = true
TableTraits.isiterabletable(x::IndexedTables.IndexedTable) = true

function TableTraits.getiterator{S<:IndexedTable}(source::S)
    return IndexedTables.rows(source)
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

    source_colnames = TableTraits.column_names(iter)
    source_coltypes = TableTraits.column_types(iter)

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
