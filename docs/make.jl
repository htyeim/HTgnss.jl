using Documenter, HTgnss

makedocs(;
    modules=[HTgnss],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/htyeim/HTgnss.jl/blob/{commit}{path}#L{line}",
    sitename="HTgnss.jl",
    authors="htyeim <htyeim@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/htyeim/HTgnss.jl",
)
