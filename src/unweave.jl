@chain begin

    single_arg(e, head) = false
    single_arg(e::Expr, head) = e.head == head && length(e.args) == 1

    replace_recursive(e, heads...) = gensym()
    replace_recursive(e::Expr) = gensym()
    replace_recursive(e::Expr, heads...) = begin
        heads, last_head = heads[1:end-1], heads[end]
        if single_arg(e, last_head)
            Expr(e.head, replace_recursive(e.args[1], heads...) )
        else
            replace_recursive(e, heads...)
        end
    end

    unparameterize(e) =
         if single_arg(e, :parameters)
             e.args[1]
         else
             e
         end

    add_key!(d, e) = begin
        if begin
            d
            haskey(_, e)
            !
        end
            result = replace_recursive(e, :..., :parameters)
            d[e] = result
        end
        unparameterize(result)
    end

end

# e = :( 1 + ~(a))
# d = Dict()
replace_record!(e, d) =
    MacroTools.@match e begin
        ~(e_) => add_key!(d, e)
        e_ => map_expression(e -> replace_record!(e, d), e)
    end

@chain begin
    dots_to_back(o::DataStructures.OrderedDict) = begin

        is_dots = (k, v) -> MacroTools.isexpr(k, :...)

        to_back = filter(is_dots, o)

        if length(to_back) > 1
            error("Can splat no more than one positional argument")
        end

        begin
            o
            filter(negate(is_dots), _)
            merge(_, to_back)
        end
    end

    parameters_to_front(o::DataStructures.OrderedDict) = begin
        is_parameters = (k, v) -> double_match(k, :parameters, :...)
        to_front = filter(is_parameters, o)
        if length(to_front) > 1
            error("Can splat no more than one keyword argument")
        end
        begin
            o
            filter(negate(is_parameters), _)
            merge(to_front, _)
        end
    end

    # e = :(~_ + 1)
    # e = :map
    split_woven(e::Expr) = begin
        d = Dict()
        e_replace = replace_record!(e, d)

        if length(d) == 0
            error("Must include at least one woven argument")
        end

        d_reorder = begin
            d
            DataStructures.OrderedDict(_)
            parameters_to_front
            dots_to_back
        end

        anonymous_function = begin
            d_reorder
            values
            Expr(:tuple, _...)
            Expr(:->, _, e_replace)
        end

        (anonymous_function, keys(d_reorder))
    end

    split_woven(e::Symbol) = e, (:_,)

end

export bit_not
"""
    bit_not

Alias for `~` for use within [`@unweave`](@ref) and [`@over`](@ref)

# examples
```jldoctest
julia> using ChainMap

julia> bit_not(1) == ~1
true
```
"""
bit_not = ~
