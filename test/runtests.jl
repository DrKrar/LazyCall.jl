using Chain
using Documenter

makedocs(
    modules = [Chain],
    format = :html,
    sitename = "Chain.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true
)
