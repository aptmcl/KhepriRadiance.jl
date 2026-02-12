using KhepriRadiance
using Documenter

makedocs(;
    modules=[KhepriRadiance],
    authors="António Menezes Leitão <antonio.menezes.leitao@gmail.com>",
    repo="https://github.com/aptmcl/KhepriRadiance.jl/blob/{commit}{path}#L{line}",
    sitename="KhepriRadiance.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aptmcl.github.io/KhepriRadiance.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aptmcl/KhepriRadiance.jl",
    devbranch="master",
)
