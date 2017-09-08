using TableTraits
using DataValues
using Nulls

# T is the type of the elements produced
# TS is a tuple type that stores the columns of the DataFrame
immutable DataFrameIterator{T, TS}
    df::DataFrames.DataFrame
    # This field hols a tuple with the columns of the DataFrame.
    # Having a tuple of the columns here allows the iterator
    # functions to access the columns in a type stable way.
    columns::TS
end

TableTraits.isiterable(x::DataFrames.DataFrame) = true
TableTraits.isiterabletable(x::DataFrames.DataFrame) = true

function TableTraits.getiterator(df::DataFrames.DataFrame)
    col_expressions = Array{Expr,1}()
    df_columns_tuple_type = Expr(:curly, :Tuple)
    for i in 1:length(df.columns)
        if isa(df.columns[i], AbstractArray{>:Null})
            push!(col_expressions, Expr(:(::), names(df)[i], DataValue{Nulls.T(eltype(df.columns[i]))}))
        else
            push!(col_expressions, Expr(:(::), names(df)[i], eltype(df.columns[i])))
        end
        push!(df_columns_tuple_type.args, typeof(df.columns[i]))
    end
    t_expr = NamedTuples.make_tuple(col_expressions)

    t2 = :(DataFrameIterator{Float64,Float64})
    t2.args[2] = t_expr
    t2.args[3] = df_columns_tuple_type

    t = eval(t2)

    e_df = t(df, (df.columns...))

    return e_df
end

function Base.length{T,TS}(iter::DataFrameIterator{T,TS})
    return size(iter.df,1)
end

function Base.eltype{T,TS}(iter::DataFrameIterator{T,TS})
    return T
end

function Base.start{T,TS}(iter::DataFrameIterator{T,TS})
    return 1
end

@generated function Base.next{T,TS}(iter::DataFrameIterator{T,TS}, state)
    constructor_call = Expr(:call, :($T))
    for i in 1:length(iter.types[2].types)
        if iter.parameters[1].parameters[i] <: DataValue
            push!(constructor_call.args, :(isnull(columns[$i][i]) ? $(iter.parameters[1].parameters[i])() : $(iter.parameters[1].parameters[i])(columns[$i][i])))
        else
            push!(constructor_call.args, :(columns[$i][i]))
        end
    end

    quote
        i = state
        columns = iter.columns
        a = $constructor_call
        return a, state+1
    end
end

function Base.done{T,TS}(iter::DataFrameIterator{T,TS}, state)
    return state>size(iter.df,1)
end

# Sink

@generated function _filldf(columns, enumerable)
    n = length(columns.types)
    push_exprs = Expr(:block)
    for i in 1:n
        if columns.parameters[i] <: AbstractArray{>:Null}
            ex = :( push!(columns[$i], isnull(i[$i]) ? null : get(i[$i])) )
        else
            ex = :( push!(columns[$i], i[$i]) )
        end
        push!(push_exprs.args, ex)
    end

    quote
        for i in enumerable
            $push_exprs
        end
    end
end

function _DataFrame(x)
    iter = getiterator(x)

    T = eltype(iter)
    if !(T<:NamedTuple)
        error("Can only collect a NamedTuple iterator into a DataFrame")
    end

    column_types = TableTraits.column_types(iter)
    column_names = TableTraits.column_names(iter)

    columns = []
    for t in column_types
        if isa(t, TypeVar)
            push!(columns, Array{Any}(0))
        elseif t <: DataValue
            push!(columns, Array{Union{t.parameters[1],Null},1}(0))
        else
            push!(columns, Array{t}(0))
        end
    end
    df = DataFrames.DataFrame(columns, fieldnames(T))
    _filldf((df.columns...), iter)
    return df
end

DataFrames.DataFrame{T<:NamedTuple}(x::Array{T,1}) = _DataFrame(x)

function DataFrames.DataFrame(x)
    if isiterabletable(x)
        return _DataFrame(x)
    else
        return convert(DataFrames.DataFrame, x)
    end
end
