struct GeneratorIterator{T, S}
    source::S
end

function TableTraits.getiterator(source::Base.Generator)
    TS = eltype(source.iter)
    T = Base.return_types(source.f, (TS,))[1]
    S = typeof(source)
    return GeneratorIterator{T,S}(source)
end

function TableTraits.isiterabletable(source::Base.Generator)
    TS = eltype(source.iter)
    T = Base.return_types(source.f, (TS,))[1]
    
    return T<:NamedTuple
end

Base.iteratorsize(::Type{T}) where {T<:GeneratorIterator} = Base.SizeUnknown()

function Base.eltype(iter::GeneratorIterator{T,S}) where {T,S}
    return T
end

function Base.start(iter::GeneratorIterator{T,S}) where {T,S}
    return start(iter.source)
end

function Base.next(iter::GeneratorIterator{T,S}, s) where {T,S}
    return next(iter.source, s)
end

function Base.done(iter::GeneratorIterator{T,S}, state) where {T,S}
    return done(iter.source, state)
end
