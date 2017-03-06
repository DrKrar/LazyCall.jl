map_expression(f, e::Expr) = Expr(e.head, map(f, e.args)...)

get_symbol(s::Symbol) = s
get_symbol(e) = gensym()

replace_record!(d, e, non_parameters, parameters) = e
replace_record!(d, e::Expr, non_parameters, parameters) =
    if MacroTools.@capture e ~inner_
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
        map_expression(e) do arg
            replace_record!(d, arg, non_parameters, parameters)
        end
    end

move_dots_to_back!(d) = sort!(d, by = key -> MacroTools.isexpr(key, :...) )

export unweave
"""
    @unweave e

Interprets `e` as a function with its arguments wrapped in `~`. Will
return a [`Call`](@ref), with an anonymous function as the first positional
argument.

Both variables and expressions can be woven in.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> list_of_numbers = [1, 2];

julia> lazy = @unweave vcat( ~list_of_numbers, ~[3, 4], 1);

julia> broadcast(lazy) == broadcast(list_of_numbers, [3, 4] ) do A, B
           vcat(A, B, 1)
       end
true
```

Variables need only be marked once as arguments.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> list_of_numbers = [1, 2];

julia> lazy = @unweave vcat( ~list_of_numbers, list_of_numbers);

julia> broadcast(lazy) == map(list_of_numbers) do number
           vcat(number, number)
       end
true
```

No more than one splatted positional argument can be woven in.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> first_nested_list = [1, 2], [3, 4];

julia> second_nested_list = [5, 6], [7, 8];

julia> lazy = @unweave vcat( ~(first_nested_list...) );

julia> broadcast(lazy) == broadcast(vcat, first_nested_list ...)
true

julia> @unweave vcat( ~(first_nested_list...), ~(second_nested_list...) )
ERROR: syntax: invalid ... on non-final argument
[...]
```

No more than one splatted keyword argument can be woven in.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> keyword_arguments(; kwargs...) = kwargs;

julia> first_keywords = keyword_arguments( a = 1, b = 2);

julia> second_keywords = keyword_arguments( c = 3, d = 4);

julia> lazy = @unweave keyword_arguments(; ~(first_keywords...) );

julia> run(lazy) == keyword_arguments(; first_keywords...)
true

julia> @unweave keyword_arguments(; ~( first_keywords...), ~( second_keywords ...) )
ERROR: Can only weave in one (set of) parameters
[...]
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
        Expr(:tuple, it, values(non_parameters)...)
        Expr(:->, it, e_replace)
    end

    ChainRecursive.@chain begin
        Expr(:parameters, keys(parameters)...)
        Expr(:call, collect_call, it, unwoven_function, keys(non_parameters)...)
    end
end

CreateMacrosFrom.@create_macros_from unweave
export @unweave
