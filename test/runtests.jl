using LazyCall
using Documenter

makedocs(
    modules = [LazyCall],
    format = :html,
    sitename = "LazyCall.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true
)
