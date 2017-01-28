using Documenter
using LazyCall

deploydocs(
    repo = "github.com/bramtayl/LazyCall.jl.git",
    target = "build",
    deps = nothing,
    make = nothing
)
