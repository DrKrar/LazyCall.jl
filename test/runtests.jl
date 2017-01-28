using ChainRecursive
using Documenter

makedocs(
    modules = [ChainRecursive],
    format = :html,
    sitename = "ChainRecursive.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true
)
