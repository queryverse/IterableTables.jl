using Documenter, IterableTables

makedocs(
	modules = [IterableTables],
	analytics="UA-132838790-1",
	sitename = "IterableTables.jl",
	pages = [
		"Introduction" => "index.md",
        "User Guide" => "userguide.md",
        "Integration Guide" => "integrationguide.md",
        "Developer Guide" => "developerguide.md"]
)

deploydocs(
    repo = "github.com/queryverse/IterableTables.jl.git"
)
