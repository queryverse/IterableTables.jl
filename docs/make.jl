using Documenter, IterableTables

makedocs(
	modules = [IterableTables],
	format = :html,
	sitename = "IterableTables.jl",
	pages = [
		"Introduction" => "index.md",
        "User Guide" => "userguide.md",
        "Integration Guide" => "integrationguide.md",
        "Developer Guide" => "developerguide.md"]
)

deploydocs(
    deps = nothing,
    make = nothing,
    target = "build",
    repo = "github.com/queryverse/IterableTables.jl.git",
    julia = "0.7"
)
