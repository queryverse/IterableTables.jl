@require DataStreams begin
using DataStreams
using WeakRefStrings

immutable DataStreamIterator{T, S<:DataStreams.Data.Source, TC, TSC}
    source::S
    schema::DataStreams.Data.Schema
end

isiterable(x::DataStreams.Data.Source) = true
isiterabletable(x::DataStreams.Data.Source) = true

function getiterator{S<:DataStreams.Data.Source}(source::S)
    if !Data.streamtype(S, Data.Field)
        error("Only sources that support field-based streaming are supported by IterableTables.")
    end

	schema = Data.schema(source)

    col_expressions = Array{Expr,1}()
    columns_tuple_type = Expr(:curly, :Tuple)
    columns_tuple_type_source = Expr(:curly, :Tuple)

    for i in 1:schema.cols
        if schema.types[i] <: WeakRefString
            col_type = String
        elseif schema.types[i] <: Nullable && schema.types[i].parameters[1] <: WeakRefString
            col_type = Nullable{String}
        else
            col_type = schema.types[i]
        end

        push!(col_expressions, Expr(:(::), schema.header[i], col_type))
        push!(columns_tuple_type.args, col_type)
        push!(columns_tuple_type_source.args, schema.types[i])
    end
    t_expr = NamedTuples.make_tuple(col_expressions)
    t_expr.args[1] = Expr(:., :NamedTuples, QuoteNode(t_expr.args[1]))

    t2 = :(DataStreamIterator{Float64,Float64,Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = typeof(source)
    t2.args[4] = columns_tuple_type
    t2.args[5] = columns_tuple_type_source

    t = eval(t2)

    e_df = t(source, schema)

    return e_df
end

function Base.length{T, S<:DataStreams.Data.Source, TC,TSC}(iter::DataStreamIterator{T,S,TC,TSC})
    return iter.schema.rows
end

function Base.eltype{T, S<:DataStreams.Data.Source, TC,TSC}(iter::DataStreamIterator{T,S,TC,TSC})
    return T
end

function Base.start{T, S<:DataStreams.Data.Source, TC,TSC}(iter::DataStreamIterator{T,S,TC,TSC})
    return 1
end

function _convertion_helper_for_datastreams(source, row, col, T)
    v = Data.streamfrom(source, Data.Field, Nullable{T}, row, col)
    if isnull(v)
        return Nullable{String}()
    else
        return Nullable{String}(String(get(v)))
    end
end

@generated function Base.next{T, S<:DataStreams.Data.Source, TC,TSC}(iter::DataStreamIterator{T,S,TC,TSC}, state)
    constructor_call = Expr(:call, :($T))
    for i in 1:length(TC.types)
        if TC.types[i] <: String
            get_expression = :(Data.streamfrom(source, Data.Field, WeakRefString, row, $i))
        elseif TC.types[i] <: Nullable && TSC.types[i].parameters[1] <: WeakRefString
            get_expression = :(_convertion_helper_for_datastreams(source, row, $i, TSC.types[$i].parameters[1]))
        else
            get_expression = :(Data.streamfrom(source, Data.Field, $(TC.types[i]), row, $i))
        end
        push!(constructor_call.args, get_expression)
    end

    quote
    	source = iter.source
        row = state
        a = $constructor_call
        return a, state+1
    end
end

function Base.done{T, S<:DataStreams.Data.Source, TC,TSC}(iter::DataStreamIterator{T,S,TC,TSC}, state)
    return Data.isdone(iter.source,state,1)
end

# DataStreams Source

type DataStreamSource{TSource,TE} <: Data.Source
    schema::Data.Schema
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

function Data.isdone{TSource,TE}(source::DataStreamSource{TSource,TE}, row, col)
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

Data.streamtype{T<:DataStreamSource}(::Type{T}, ::Type{Data.Field}) = true

function Data.streamfrom{T}(source::DataStreamSource, ::Type{Data.Field}, ::Type{T}, row, col)
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

function Data.streamfrom{T}(source::DataStreamSource, ::Type{Data.Field}, ::Type{Nullable{T}}, row, col)
    row==source.current_row || row==source.current_row+1 || error()

    if source.current_row==0
        source.iterate_state = start(source.data)
    end

    if row==source.current_row+1
        (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
        source.current_row = source.current_row+1
    end

    val = source.current_val[col]

    if typeof(val) <: Nullable
        if isnull(val)
            return Nullable{T}()
        else
            return Nullable{T}(get(val))
        end
    else
        return Nullable{T}(val)
    end
end

function Data.schema(source::DataStreamSource)
    return source.schema
end

function Data.schema(source::DataStreamSource, ::Type{Data.Field})
    return Data.schema(source)
end

function get_datastreams_source{S}(source::S)
    isiterabletable(source) || error()

    iter = getiterator(source)

    column_types = IterableTables.column_types(iter)
    column_names = IterableTables.column_names(iter)


    schema = Data.Schema(column_names, column_types, -1)
    source = DataStreamSource{typeof(iter),eltype(iter)}(schema, iter)
    return source
end

end
