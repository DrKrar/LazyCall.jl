basic_method(f) = :(
    $f(c::$Call, positional...; keyword...) =
        if length(c.positional) == 0
            error("Must include at least on positional argument to the Call")
        else
            $f(c.positional[1], positional..., c.positional[2:end]...;
                c.keyword..., keyword...)
        end
)

lazy_call_method(a_module, f) = basic_method( :($a_module.$f) )

map_block(f, es) = Expr(:block, map(f, es)...)

export lazy_call_methods

"""
    @lazy_call_methods a_module fs...

For each function in `fs` in `a_module`, create a method that takes a
[`Call`](@ref). This method will make assumptions about argument order.
Positional arguments from the outer call will be inserted between the first
(typically a function) and second positional arguments of the inner
[`Call`]. This makes sense in many cases. For more complicated cases, like
`mapreducedim`, `Call` methods can be defined by hand.

```jldoctest
julia> using LazyCall, ChainRecursive

julia> @lazy_call_methods Base Generator mapreduce

julia> version_1 = @chain begin
           [-2, 0, -2, 0]
           @unweave ~_ + 1 > 0
           Base.Generator(_)
           sum(_)
        end
2

julia> version_2 = @chain begin
           [-2, 0, -2, 0]
           @unweave ~_ + 1 > 0
           mapreduce(_, +)
       end
2

julia> version_1 == version_2
true
```
"""
lazy_call_methods(a_module, fs...) =
    map_block(f -> lazy_call_method(a_module, f), fs)

CreateMacrosFrom.@create_macros_from lazy_call_methods
export @lazy_call_methods

@lazy_call_methods Base broadcast

# disambiguation method
Base.broadcast(c::Call, x::Number...) =
    if length(c.positional) == 0
        error("Must include at least on positional argument to the Call")
    else
        Base.broadcast(c.positional[1], x..., c.positional[2:end]...;
        c.keyword...)
    end
