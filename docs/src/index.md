# LazyCall.jl

LazyCall allows you to store a function along with its arguments for later use.
This is particularly useful in functional programming. Here's a quick demo:

```jldoctest
julia> using ChainRecursive, LazyCall, Base.Generator

julia> @chain begin
           [-2, 0, -2, 0]
           @unweave ~_ + 1 > 0
           Generator
           sum
       end
2
```

Methods on LazyCalls are currently defined for only four base functions: `map`,
`filter`, `broadcast`, and `Base.Generator`. However, there is the potential for
many more methods. I've created a wish-list issue on github for ideas.

```@index
```

```@autodocs
Modules = [LazyCall]
```
