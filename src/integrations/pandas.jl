@require Pandas begin
using DataValues

isiterable(x::Pandas.DataFrame) = true
isiterabletable(x::Pandas.DataFrame) = true

function getiterator(df::Pandas.DataFrame)
    col_names = [Symbol(i) for i in Pandas.columns(df)]

    columns = [Pandas.values(df[i]) for i in col_names]

    return create_tableiterator(columns, col_names)
end

end
