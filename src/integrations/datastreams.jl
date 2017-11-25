@require DataStreams begin
using TableTraits
using DataStreams
using WeakRefStrings
using Nulls

struct DataStreamIterator{T, S<:DataStreams.Data.Source, types}
    source::S
end

TableTraits.isiterable(x::DataStreams.Data.Source) = true
TableTraits.isiterabletable(x::DataStreams.Data.Source) = true
TableTraits.isiterabletable(x::DataStreamIterator) = true

function TableTraits.getiterator(source::S) where {S<:DataStreams.Data.Source}
    if !Data.streamtype(S, Data.Field)
        error("Only sources that support field-based streaming are supported by IterableTables.")
    end

    schema = Data.schema(source)
    types = Data.types(schema)

    col_expressions = Array{Expr,1}()
    columns_tuple_type = Expr(:curly, :Tuple)

    for i in 1:schema.cols
        col_type = types[i]

        push!(col_expressions, Expr(:(::), schema.header[i], col_type))
        push!(columns_tuple_type.args, col_type)
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(DataStreamIterator{Float64,Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = typeof(source)
    t2.args[4] = columns_tuple_type

    t = eval(t2)

    e_df = t(source)

    return e_df
end

function Base.length(iter::DataStreamIterator)
    return iter.schema.rows
end

function Base.eltype(iter::DataStreamIterator{T}) where {T}
    return T
end

function Base.start(iter::DataStreamIterator)
    return 1
end

@generated function Base.next(iter::DataStreamIterator{T,S,TC}, state) where {T, S<:DataStreams.Data.Source, TC}
    constructor_call = Expr(:call, :($T))
    for i in 1:length(TC.types)
        get_expression = :(v = Data.streamfrom(source, Data.Field, $(TC.types[i]), row, $i); v isa Null ? null : v)
        push!(constructor_call.args, get_expression)
    end

    quote
    	source = iter.source
        row = state
        a = $constructor_call
        return a, state+1
    end
end

function Base.done(iter::DataStreamIterator{T,S,TC}, state) where {T, S<:DataStreams.Data.Source, TC}
    return Data.isdone(iter.source,state,1)
end

# DataStreams Source

mutable struct DataStreamSource{TSource,TE} <: Data.Source
    _schema::Data.Schema
    data::TSource
    iterate_state
    current_row::Int
    current_val::TE
    function DataStreamSource{TSource,TE}(schema, data) where {TSource,TE}
        x = new(schema, data)
        x.current_row = 0
        return x
    end
end

function Data.isdone(source::DataStreamSource{TSource,TE}, row, col) where {TSource,TE}
    row==source.current_row || row==source.current_row+1 || error()

    if source.current_row==0
        source.iterate_state = start(source.data)
    end

    if row==source.current_row+1
        if done(source.data, source.iterate_state)
            return true
        else
            (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
            source.current_row = source.current_row+1
        end
    end

    return false
end

Data.streamtype(::Type{T}, ::Type{Data.Field}) where {T<:DataStreamSource} = true

function Data.streamfrom(source::DataStreamSource, ::Type{Data.Field}, ::Type{T}, row, col) where {T}
    row==source.current_row || row==source.current_row+1 || error()

    if source.current_row==0
        source.iterate_state = start(source.data)
    end

    if row==source.current_row+1
        (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
        source.current_row = source.current_row+1
    end

    return source.current_val[col]::T
end

function Data.schema(source::DataStreamSource)
    return source._schema
end

function get_datastreams_source(source::S) where {S}
    isiterabletable(source) || error()

    iter = getiterator(source)

    column_types = TableTraits.column_types(iter)
    column_names = TableTraits.column_names(iter)

    schema = Data.Schema(column_types, column_names, null)
    source = DataStreamSource{typeof(iter),eltype(iter)}(schema, iter)
    return source
end

end
