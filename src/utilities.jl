function column_names(iter)    
    T = eltype(iter)

    if !(T<:NamedTuple)
        error()
    end

    names = fieldnames(T)

    return names
end

function column_types(iter)
    T = eltype(iter)

    if !(T<:NamedTuple)
        error()
    end

    types = T.parameters
    
    return types
end

function column_count(iter)
    T = eltype(iter)

    if !(T<:NamedTuple)
        error()
    end

    return length(T.parameters)
end
