# type piracy guilt
Base.map(f, e::Expr) = Expr(e.head, map(f, e.args)...)

get_symbol(s::Symbol) = s
get_symbol(e) = gensym()

# parameters = Dict()
# non_parameters = Dict()
# d = Dict()
# e = :( vcat(~A, ~A, ~[1, 2], ~(B...); ~(C...) ) )
# e = :( keyword_arguments(; ~(A...) ) )
replace_record!(d, e, non_parameters, parameters) = e
replace_record!(d, e::Expr, non_parameters, parameters) =
    if MacroTools.@capture e ~(inner_)
        if haskey(d, inner)
            d[inner]
        else
            replaced = MacroTools.@match inner begin
                e_... => Expr(:..., get_symbol(e) )
                e_ => get_symbol(e)
            end
            d[inner] = replaced
            replaced
        end
    else
        d = if e.head == :parameters
            parameters
        else
            non_parameters
        end
        map(e -> replace_record!(d, e, non_parameters, parameters), e)
    end

move_dots_to_back!(d) = sort!(d, by = key -> MacroTools.isexpr(key, :...) )

"""
    @unweave e

Interprets `e` as a function with its arguments wrapped in tildas and woven into
it. Will return a [`Call`](@ref), with an anonymous function as the first
positional argument.

Both variables and expressions can be woven in.
```jldoctest
julia> using LazyCall

julia> A = [1, 2];

julia> map( @unweave vcat(~A, ~[3, 4] ) ) == map(vcat, A, [3, 4])
true
```

Variables need only be marked once as arguments.
```jldoctest
julia> using LazyCall

julia> A = [1, 2];

julia> map( @unweave vcat(~A, A) ) == map( @unweave vcat(~A, ~A) )
true
```

No more than one splatted positional argument can be woven in.
```jldoctest
julia> using LazyCall

julia> A = [1, 2], [3, 4];

julia> B = [5, 6], [7, 8];

julia> map( @unweave vcat( ~(A...) ) ) == map(vcat, A...)
true

julia> @unweave vcat( ~(A...), ~(B...) )
ERROR: syntax: invalid ... on non-final argument
[...]
```

No more than one splatted keyword argument can be woven in.
```jldoctest
julia> using LazyCall

julia> keyword_arguments(; kwargs...) = kwargs;

julia> A = keyword_arguments( a = 1, b = 2);

julia> B = keyword_arguments( c = 3, d = 4);

julia> run( @unweave keyword_arguments(; ~(A...) ) ) ==
           keyword_arguments(; A...)
true

julia> @unweave keyword_arguments(; ~( A...), ~(B...) )
ERROR: Can only weave in one (set of) parameters
[...]
```

With no woven arguments, `Call` will only contain a dummy anonymous function.

```jldoctest
julia> using LazyCall

julia> run( @unweave 1)
1
```
"""
unweave(e) = begin
    non_parameters = DataStructures.OrderedDict()
    parameters = DataStructures.OrderedDict()
    e_replace = replace_record!(non_parameters, e, non_parameters, parameters)

    if length(parameters) > 1
        error("Can only weave in one (set of) parameters")
    end

    move_dots_to_back!(non_parameters)
    move_dots_to_back!(parameters)

    unwoven_function = ChainRecursive.@chain begin
        Expr(:parameters, values(parameters)...)
        Expr(:tuple, _, values(non_parameters)...)
        Expr(:->, _, e_replace)
    end

    ChainRecursive.@chain begin
        Expr(:parameters, keys(parameters)...)
        Expr(:call, collect_call, _, unwoven_function, keys(non_parameters)...)
    end
end

CreateMacrosFrom.@create_macros_from unweave
export @unweave

export bit_not
"""
    bit_not

Alias for `~` for use within [`@unweave`](@ref).

# examples
```jldoctest
julia> using LazyCall

julia> bit_not(1) == ~1
true
```
"""
bit_not = ~
