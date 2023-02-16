using Jupyter2Pluto
using Documenter

DocMeta.setdocmeta!(Jupyter2Pluto, :DocTestSetup, :(using Jupyter2Pluto); recursive=true)

makedocs(;
    modules=[Jupyter2Pluto],
    authors="Adrian Hill <adrian.hill@mailbox.org>",
    repo="https://github.com/adrhill/Jupyter2Pluto.jl/blob/{commit}{path}#{line}",
    sitename="Jupyter2Pluto.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://adrhill.github.io/Jupyter2Pluto.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/adrhill/Jupyter2Pluto.jl",
    devbranch="main",
)
