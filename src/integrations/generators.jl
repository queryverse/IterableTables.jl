immutable GeneratorIterator{T, S}
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

Base.iteratorsize{T<:GeneratorIterator}(::Type{T}) = Base.SizeUnknown()

function Base.eltype{T,S}(iter::GeneratorIterator{T,S})
    return T
end

function Base.start{T,S}(iter::GeneratorIterator{T,S})
    return start(iter.source)
end

function Base.next{T,S}(iter::GeneratorIterator{T,S}, s)
    return next(iter.source, s)
end

function Base.done{T,S}(iter::GeneratorIterator{T,S}, state)
    return done(iter.source, state)
end
