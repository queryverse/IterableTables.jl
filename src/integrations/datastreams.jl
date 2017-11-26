@require DataStreams begin
using TableTraits
using DataStreams
using WeakRefStrings
using DataValues

struct DataStreamIterator{T, S<:DataStreams.Data.Source, TC, TSC}
    source::S
    schema::DataStreams.Data.Schema
end

TableTraits.isiterable(x::DataStreams.Data.Source) = true
TableTraits.isiterabletable(x::DataStreams.Data.Source) = true

function TableTraits.getiterator(source::S) where {S <: DataStreams.Data.Source}
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
            col_type = DataValue{String}
        elseif schema.types[i] <: Nullable
            col_type = DataValue{schema.types[i].parameters[1]}
        else
            col_type = schema.types[i]
        end

        push!(col_expressions, Expr(:(::), schema.header[i], col_type))
        push!(columns_tuple_type.args, col_type)
        push!(columns_tuple_type_source.args, schema.types[i])
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(DataStreamIterator{Float64,Float64,Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = typeof(source)
    t2.args[4] = columns_tuple_type
    t2.args[5] = columns_tuple_type_source

    t = eval(t2)

    e_df = t(source, schema)

    return e_df
end

function Base.length(iter::DataStreamIterator{T,S,TC,TSC}) where {T,S <: DataStreams.Data.Source,TC,TSC}
    return iter.schema.rows
end

function Base.eltype(iter::DataStreamIterator{T,S,TC,TSC}) where {T,S <: DataStreams.Data.Source,TC,TSC}
    return T
end

function Base.start(iter::DataStreamIterator{T,S,TC,TSC}) where {T,S <: DataStreams.Data.Source,TC,TSC}
    return 1
end

function _convertion_helper_for_datastreams(source, row, col, T)
    v = Data.streamfrom(source, Data.Field, Nullable{T}, row, col)
    if isnull(v)
        return DataValue{String}()
    else
        return DataValue{String}(String(get(v)))
    end
end

@generated function Base.next(iter::DataStreamIterator{T,S,TC,TSC}, state) where {T,S <: DataStreams.Data.Source,TC,TSC}
    constructor_call = Expr(:call, :($T))
    for i in 1:length(TC.types)
        if TC.types[i] <: String
            get_expression = :(Data.streamfrom(source, Data.Field, WeakRefString, row, $i))
        elseif TC.types[i] <: DataValue && TSC.types[i].parameters[1] <: WeakRefString
            get_expression = :(_convertion_helper_for_datastreams(source, row, $i, TSC.types[$i].parameters[1]))
        elseif TC.types[i] <: DataValue
            get_expression = :(DataValue(Data.streamfrom(source, Data.Field, $(Nullable{TC.types[i].parameters[1]}), row, $i)))
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

function Base.done(iter::DataStreamIterator{T,S,TC,TSC}, state) where {T,S <: DataStreams.Data.Source,TC,TSC}
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

Data.streamtype(::Type{T}, ::Type{Data.Field}) where {T <: DataStreamSource} = true

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

function Data.streamfrom(source::DataStreamSource, ::Type{Data.Field}, ::Type{Nullable{T}}, row, col) where {T}
    row==source.current_row || row==source.current_row+1 || error()

    if source.current_row==0
        source.iterate_state = start(source.data)
    end

    if row==source.current_row+1
        (source.current_val, source.iterate_state) = next(source.data, source.iterate_state)
        source.current_row = source.current_row+1
    end

    val = source.current_val[col]

    if typeof(val) <: DataValue
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
    return source._schema
end

function Data.schema(source::DataStreamSource, ::Type{Data.Field})
    return Data.schema(source)
end

function get_datastreams_source(source::S) where {S}
    isiterabletable(source) || error()

    iter = getiterator(source)

    column_types = TableTraits.column_types(iter)
    column_names = TableTraits.column_names(iter)

    for (i,v) in enumerate(column_types)
        if v <: DataValue
            column_types[i] = Nullable{v.parameters[1]}
        end
    end

    schema = Data.Schema(column_names, column_types, -1)
    source = DataStreamSource{typeof(iter),eltype(iter)}(schema, iter)
    return source
end

end
