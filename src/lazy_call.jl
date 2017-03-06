export LazyCall
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

You can `copy` them to avoid accidentally overwriting keyword arguments.
```jldoctest
julia> using LazyCall

julia> test = collect_call(a = 1);

julia> copy_test = copy(test);

julia> copy_test.keyword[:b] = 2;

julia> test.keyword == copy_test.keyword
false
```

You can `merge` two `Call`s, optionally at a specific position.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> base = collect_call(1, 2, a = 3, b = 4);

julia> addition = collect_call(5, a = 6, c = 7);

julia> merge(base, addition) == collect_call(1, 2, 5; a = 6, b = 4, c = 7)
true

julia> merge(base, addition, 2) == collect_call(1, 5, 2; a = 6, b = 4, c = 7)
true

julia> merge(base, addition, 4)
ERROR: Call `a` must have at least `position` - 1 positional arguments
[...]
```

You can `push`, `unshift`, or `insert` in new arguments.
```jldoctest
julia> using LazyCall, ChainRecursive

julia> base = collect_call(1, 2, a = 3, b = 4);

julia> push(base, 5, a = 6, c = 7) ==
           collect_call(1, 2, 5; a = 6, b = 4, c = 7)
true

julia> unshift(base, 5, a = 6, c = 7) ==
           collect_call(5, 1, 2; a = 6, b = 4, c = 7)
true

julia> insert(base, 2, 5, a = 6, c = 7) ==
           collect_call(1, 5, 2; a = 6, b = 4, c = 7)
true
```

You can `run` a function on a call.

```jldoctest
julia> using LazyCall, ChainRecursive

julia> @chain begin
           collect_call(1, 2)
           run(it, vcat)
       end
2-element Array{Int64,1}:
 1
 2
```

If you `run` a `Call` by itself, it calls the first positional argument on the
rest of the positional and keyword arguments.

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

Base.merge(a::Call, b::Call, position = length(a.positional) + 1) = begin
    if length(a.positional) < position - 1
        error("Call `a` must have at least `position` - 1 positional arguments")
    end
    Call(
        (a.positional[1:position - 1]..., b.positional..., a.positional[position:end]...),
        merge(a.keyword, b.keyword)
    )
end

export push
push(a::Call, positional...; keyword...) =
    merge(a, collect_call(positional...; keyword...) )

export unshift
unshift(a::Call, positional...; keyword...) =
    merge(a, collect_call(positional...; keyword...), 1 )

export insert
insert(a::Call, position, positional...; keyword...) =
    merge(a, collect_call(positional...; keyword...), position)

export collect_call
"""
    collect_call(positional...; keyword...)

Collect a [`Call`](@ref).
"""
collect_call(positional...; keyword...) =
    Call(positional, Dict(keyword) )

import Base.==

==(a::Call, b::Call) =
    (a.positional == b.positional) && (a.keyword == b.keyword)

Base.copy(c::Call) = Call(c.positional, copy(c.keyword) )

Base.run(l::Call) = begin
    l.positional[1](l.positional[2:end]...; l.keyword...)
end

Base.run(l::Call, f) = begin
    f(l.positional...; l.keyword...)
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
            reduce(paste_two, it)
            string("; ", it)
        end
    end

    string(positional_string, keyword_string)
end

Base.show(io::IO, c::Call) = print(io, string(c) )
