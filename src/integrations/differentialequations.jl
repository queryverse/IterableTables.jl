@require DiffEqBase begin

immutable DESolutionIterator{T}
    sol::T
end

isiterable(sol::DiffEqBase.DESolution) = true
isiterabletable(sol::DiffEqBase.DESolution) = true

function getiterator(sol::DiffEqBase.DESolution)
    return DESolutionIterator(sol)
end

function Base.length(iter::DESolutionIterator)
    return length(iter.sol)
end

function Base.eltype(iter::DESolutionIterator)
    timestamp_type = eltype(iter.sol.t)
    value_type = eltype(iter.sol.u)
    
    return @NT(timestamp, value){timestamp_type, value_type}
end

function Base.start(iter::DESolutionIterator)
    return 1
end

function Base.next(iter::DESolutionIterator, state)
    i = state
    a = @NT(timestamp=iter.sol.t[i], value=iter.sol.u[i])
    return a, state+1
end

function Base.done(iter::DESolutionIterator, state)
    return state>length(iter.sol)
end

end
