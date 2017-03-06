lazy_call_method(f) = :(
    $f(c::$Call, positional...; keyword...) =
        run(insert(c, 2, positional...; keyword...), $f)
)

lazy_call_module_method(a_module, f) = lazy_call_method( :($a_module.$f) )

map_block(f, es) = Expr(:block, map(f, es)...)

export lazy_call_methods
"""
    @lazy_call_methods fs...

For each function in `fs`, create a method that takes aWW
[`Call`](@ref). This method will make assumptions about argument order.
Positional arguments from the outer call will be inserted between the first
(typically a function) and second positional arguments of the inner
`Call`. This makes sense in many cases. For more complicated cases, like
`mapreducedim`, `Call` methods can be defined by hand. Robost lazy
systems would likely need to make use of a much more complicated type
hierarchy than can be automatically generated.

```jldoctest
julia> using LazyCall, ChainRecursive

julia> run_it_once(f, e) = f(e);

julia> run_it_twice(f, e) = run_it_once(f, run_it_once(f, e) );

julia> run_it_thrice(f, e) = run_it_twice(f, run_it_once(f, e) );

julia> @lazy_call_methods run_it_once run_it_twice run_it_thrice;

julia> initial_number = 0;

julia> run_it_thrice( @unweave ~initial_number + 1)
3
```
"""
lazy_call_methods(fs...) = map_block(fs) do f
    lazy_call_method(f)
end

export lazy_call_module_methods

"""
    @lazy_call_methods a_module fs...

Same as [`lazy_call_methods`](@ref) `fs` functions that are in `a_module`.

```jldoctest
julia> using LazyCall, ChainRecursive

julia> @lazy_call_module_methods Base Generator mapreduce

julia> version_1 = @chain begin
           [-2, 0, -2, 0]
           @unweave ~it + 1 > 0
           Base.Generator(it)
           sum(it)
        end
2

julia> version_2 = @chain begin
           [-2, 0, -2, 0]
           @unweave ~it + 1 > 0
           mapreduce(it, +)
       end
2

julia> version_1 == version_2
true
```
"""
lazy_call_module_methods(a_module, fs...) = map_block(fs) do f
    lazy_call_module_method(a_module, f)
end

CreateMacrosFrom.@create_macros_from lazy_call_methods lazy_call_module_methods
export @lazy_call_methods
export @lazy_call_module_methods

@lazy_call_module_methods Base broadcast

# disambiguation method
Base.broadcast(c::Call, x::Number...) =
    run(insert(c, 2, x...), Base.broadcast)
