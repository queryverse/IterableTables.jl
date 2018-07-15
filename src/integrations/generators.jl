struct GeneratorWithElType{T, S}
    source::S
end

function IteratorInterfaceExtensions.getiterator(source::Base.Generator)
    TS = eltype(source.iter)
    T = Base.return_types(source.f, (TS,))[1]
    S = typeof(source)

    if isconcretetype(T)
        return GeneratorWithElType{T,S}(source)
    else
        return source
    end
end

function TableTraits.isiterabletable(source::Base.Generator)
    TS = eltype(source.iter)
    T = Base.return_types(source.f, (TS,))[1]

    if isconcretetype(T)
        if T <: NamedTuple
            return true
        else
            return false
        end
    else
        return missing
    end
end

Base.IteratorSize(::Type{GeneratorWithElType{T,S}}) where {T,S} = Base.IteratorSize(S)

Base.size(it::GeneratorWithElType, dims...) = size(it.source, dims...)

Base.length(it::GeneratorWithElType) = length(it.source)

Base.eltype(::Type{GeneratorWithElType{T,TS}}) where {T,TS} = T

Base.iterate(it::GeneratorWithElType) = iterate(it.source)

Base.iterate(it::GeneratorWithElType, state) = iterate(it.source, state)
