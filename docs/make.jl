using Documenter, IterableTables

makedocs(
	modules = [IterableTables],
	format = :html,
	sitename = "IterableTables.jl",
	pages = [
		"Introduction" => "index.md"]
)

deploydocs(
    deps = nothing,
    make = nothing,
    target = "build",
    repo = "github.com/davidanthoff/IterableTables.jl.git",
    julia = "0.5"
)
