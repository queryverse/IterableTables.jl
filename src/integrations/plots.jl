@require RecipesBase begin

import RecipesBase
import DataFrames

@traitfn function RecipesBase.apply_recipe{X; IsIterableTable{X}}(d::Dict{Symbol,Any},::Type{X},source::X)
    if RecipesBase._debug_recipes[1]
        println("apply_recipe args: ",Any[:(::Type{IsIterableTable}),:(source::IsIterableTable)])
    end
    series_list = RecipesBase.RecipeData[]
    func_return = begin
        DataFrames.DataFrame(source)
    end
    if func_return != nothing
        push!(series_list,RecipesBase.RecipeData(d,RecipesBase.wrap_tuple(func_return)))
    end
    series_list
end

end
