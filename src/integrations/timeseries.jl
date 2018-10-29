struct TimeArrayIterator{T, S}
    source::S
end

IteratorInterfaceExtensions.isiterable(x::TimeSeries.TimeArray) = true
TableTraits.isiterabletable(x::TimeSeries.TimeArray) = true

function IteratorInterfaceExtensions.getiterator(ta::S) where {S<:TimeSeries.TimeArray}
    etype = eltype(TimeSeries.values(ta))
    
    T = NamedTuple{(:timestamp, Symbol.(TimeSeries.colnames(ta))...), Tuple{S.parameters[3], fill(etype, length(TimeSeries.colnames(ta)))...}}

    return TimeArrayIterator{T, S}(ta)
end

function Base.length(iter::TimeArrayIterator)
    return length(iter.source)
end

function Base.eltype(iter::TimeArrayIterator{T,TS}) where {T,TS}
    return T
end

Base.eltype(::Type{TimeArrayIterator{T,TS}}) where {T,TS} = T

@generated function Base.iterate(iter::TimeArrayIterator{T,TS}, state=1) where {T,TS}
    constructor_call = Expr(:call, :($T))

    push!(constructor_call.args, Expr(:tuple))

    # Add timestamp column
    push!(constructor_call.args[2].args, :(TimeSeries.timestamp(iter.source)[i]))

    for i in 1:fieldcount(T)-1
        push!(constructor_call.args[2].args, :(TimeSeries.values(iter.source)[i,$i]))
    end

    quote
        if state>length(TimeSeries.timestamp(iter.source))
            return nothing
        else
            i = state
            a = $constructor_call
            return a, state+1
        end
    end
end

# Sink

function TimeSeries.TimeArray(x; timestamp_column::Symbol=:timestamp)
    TableTraits.isiterabletable(x) || error("Cannot create a TimeArray from something that is not a table.")

    iter = IteratorInterfaceExtensions.getiterator(x)

    et = eltype(iter)
    
    if fieldcount(et)<2
        error("Need at least two columns")
    end

    names = fieldnames(et)
    
    timestep_col_index = findfirst(isequal(timestamp_column), names)

    if timestep_col_index===nothing
        error("No timestamp column found.")
    end

    timestep_col_index = something(timestep_col_index)
    
    col_types = [fieldtype(et, i) for i=1:fieldcount(et)]

    data_columns = collect(Iterators.filter(i->i[2][1]!=timestamp_column, enumerate(zip(names, col_types))))

    orig_data_type = data_columns[1][2][2]

    data_type = orig_data_type <: DataValues.DataValue ? orig_data_type.parameters[1] : orig_data_type

    orig_timestep_type = col_types[timestep_col_index]

    timestep_type = orig_timestep_type <: DataValues.DataValue ? orig_timestep_type.parameters[1] : orig_timestep_type

    if any(i->i[2][2]!=orig_data_type, data_columns)
        error("All data columns need to be of the same type.")
    end

    t_column = Vector{timestep_type}(undef,0)
    d_array = Vector{Vector{data_type}}(undef,0)
    for i in data_columns
        push!(d_array, Vector{data_type}(undef,0))
    end

    for v in iter
        if orig_timestep_type <: DataValue
            push!(t_column, get(v[timestep_col_index]))
        else
            push!(t_column, v[timestep_col_index])
        end

        if orig_data_type <: DataValue
            for (i,c) in enumerate(data_columns)
                push!(d_array[i],get(v[c[1]]))
            end
        else
            for (i,c) in enumerate(data_columns)
                push!(d_array[i],v[c[1]])
            end
        end
    end

    d_array = hcat(d_array...)

    ta = TimeSeries.TimeArray(t_column,d_array,[i[2][1] for i in data_columns])
    return ta
end
