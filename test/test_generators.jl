@testitem "Generators" begin
    using IteratorInterfaceExtensions
    using TableTraits
    using TableTraitsUtils
    using Query
    using DataFrames

    g = ((a=i, b=Float64(i)^2, c="x$i") for i in 1:5)

    @test TableTraits.isiterabletable(g) == true
    @test IteratorInterfaceExtensions.isiterable(g) == true

    it = IteratorInterfaceExtensions.getiterator(g)
    @test eltype(it) == @NamedTuple{a::Int, b::Float64, c::String}
    @test length(it) == 5
    @test collect(it) == [(a=i, b=Float64(i)^2, c="x$i") for i in 1:5]

    columns, names = TableTraitsUtils.create_columns_from_iterabletable(g)
    @test names == [:a, :b, :c]
    @test columns[1] == 1:5
    @test columns[2] == (1:5) .^ 2
    @test columns[3] == ["x$i" for i in 1:5]

    # a generator is a source for a Query pipeline ending in any sink
    df = g |> @filter(_.a > 2) |> @map({_.a, _.b}) |> DataFrame
    @test size(df) == (3, 2)
    @test df[!, :a] == [3, 4, 5]
    @test df[!, :b] == [9.0, 16.0, 25.0]

    # a generator with a non-NamedTuple eltype is not an iterable table
    @test TableTraits.isiterabletable(i^2 for i in 1:3) == false
end
