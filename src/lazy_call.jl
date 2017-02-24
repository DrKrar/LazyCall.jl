export Call
"""
    immutable Call

Will store positional and keyword arguments. Create with
[`collect_call`](@ref) or [`unweave`](@ref).

You can include positional arguments, keyword arguments, or both.
```jldoctest
julia> using LazyCall

julia> collect_call(1, 2)
1, 2

julia> collect_call(a = 1, b = 2)
; a = 1, b = 2

julia> collect_call(1, 2, a = 1, b = 2)
1, 2; a = 1, b = 2
```

They are equal if all of their elements are equal and the positional arguments
are in the right order. Keyword order doesn't matter.
```jldoctest
julia> using LazyCall

julia> collect_call(1, 2, a = 1, b = 2) == collect_call(1, 2, b = 2, a = 1)
true
```

You can `merge` two `Call`s.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> @chain begin
           merge(
               collect_call(1, a = 2, b = 3),
               collect_call(4, a = 5, c = 6)
            )
            _ == collect_call(1, 4; a = 5, b = 3, c = 6)
       end
true
```

You can [`push`](@ref) in new arguments.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> @chain begin
           collect_call(1, a = 2, b = 3)
           push(_, 4, a = 5, c = 6)
           _ == collect_call(1, 4; a = 5, b = 3, c = 6)
       end
true
```

You can [`unshift`](@ref) in new arguments.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> @chain begin
           collect_call(1, a = 2, b = 3)
           unshift(_, 4, a = 5, c = 6)
           _ == collect_call(4, 1; a = 2, b = 3, c = 6)
       end
true
```

When you `run` a `Call`, it calls the first positional argument on the rest of
the positional and keyword arguments.

```jldoctest
julia> using LazyCall

julia> collect_call(vcat, 1, 2) |> run
2-element Array{Int64,1}:
 1
 2
```
"""
immutable Call
    positional::Tuple
    keyword::Dict{Symbol, Any}
end

Base.merge(a::Call, b::Call) =
    Call( (a.positional..., b.positional...), merge(a.keyword, b.keyword) )

export push
"""
    push

Same as `push!` but will leave arguments unchanged.
"""
push(l::Call, positional...; keyword...) =
    merge(l, Call(positional, Dict(keyword) ) )

export unshift
"""
    unshift

Same as `unshift!` but will leave arguments unchanged.
"""
unshift(l::Call, positional...; keyword...) =
    merge(Call(positional, Dict(keyword) ), l)

export collect_call
"""
    collect_call(positional...; keyword...)

Collect a [`Call`](@ref).

```jldoctest
julia> using LazyCall

julia> collect_call(1, 2, a = 1, b = 2)
1, 2; a = 1, b = 2
```
"""
collect_call(positional...; keyword...) =
    Call(positional, Dict(keyword) )

import Base.==

==(a::Call, b::Call) =
    (a.positional == b.positional) && (a.keyword == b.keyword)

Base.run(l::Call) = if length(l.positional) > 1
    l.positional[1](l.positional[2:end]...; l.keyword...)
else
    l.positional[1](; l.keyword...)
end

paste_two(a, b) = string(a, ", ", b)

Base.string(c::Call) = begin
    positional_string = if isempty(c.positional)
        ""
    else
        positional_string = reduce(paste_two, c.positional)
    end

    keyword_string = if isempty(c.keyword)
        ""
    else
        ChainRecursive.@chain begin
            ( string(k, " = ", v) for (k, v) in c.keyword )
            reduce(paste_two, _)
            string("; ", _)
        end
    end

    string(positional_string, keyword_string)
end

Base.show(io::IO, c::Call) = print(io, string(c) )
