export Arguments
"""
    immutable Arguments
        positional::Tuple
        keyword::Dict{Symbol, Any}
    end

Will store positional and keyword arguments for later use.

Create with [`collect_arguments`](@ref). You can also `merge` two
`Arguments`, [`push`](@ref) in new arguments, and `run`.

# examples
```jldoctest
julia> using ChainRecursive

julia> @chain begin
           collect_arguments(1, a = 2, b = 3)
           merge(_, collect_arguments(4, a = 5, c = 6) )
           push(_, 7, b = 8)
       end
1, 4, 7; c = 6, a = 5, b = 8

julia> @chain begin
           collect_arguments( vcat, [1, 2], [3, 4] )
           run(_, map)
       end
Array{Int64,1}[[1,3],[2,4]]
```
"""
immutable Arguments
  positional::Tuple
  keyword::Dict{Symbol, Any}
end

export Call
"""
    immutable Call
        arguments::Arguments
        function_call
    end

Will store a function along with its arguments for later use. Create
with [`collect_call`](@ref). You can also `merge` in more
[`Arguments`](@ref), [`push`](@ref) in new arguments, and `run`.

# examples
```jldoctest
julia> using ChainRecursive

julia> @chain begin
           collect_call(vcat, 1, a = 2, b = 3)
           merge(_, collect_arguments(4, a = 5, c = 6) )
           push(_, 7, b = 8)
        end
vcat(1, 4, 7; c = 6, a = 5, b = 8)

julia> @chain begin
           collect_call(map, vcat, [1, 2], [3, 4] )
           run
       end
Array{Int64,1}[[1,3],[2,4]]
```
"""
immutable Call
    arguments
    function_call
end

Base.merge(a::Arguments, b::Arguments) = begin
    positional = (a.positional..., b.positional...)
    keyword = merge(a.keyword, b.keyword)
    Arguments(positional, keyword)
end

Base.merge(lazycall::Call, arguments::Arguments) = ChainRecursive.@chain begin
    lazycall.arguments
    merge(_, arguments)
    Call(_, lazycall.function_call)
end

export push
"""
    push

Same as `push!` but will leave arguments unchanged.
"""
push(a::Arguments, positional...; keyword...) = ChainRecursive.@chain begin
    keyword
    Dict(_)
    Arguments(positional, _)
    merge(a, _)
end

push(lazycall::Call, positional...; keyword...) = ChainRecursive.@chain begin
    lazycall.arguments
    push(_, positional...; keyword...)
    Call(_, lazycall.function_call)
end

export collect_arguments
"""
    collect_arguments(positional...; keyword...)

See [`Arguments`](@ref).
"""
collect_arguments(positional...; keyword...) = ChainRecursive.@chain begin
    keyword
    Dict
    Arguments(positional, _)
end

export collect_call
"""
    collect_call(f, positional...; keyword...)

See [`Call`](@ref).
"""
collect_call(f, positional...; keyword...) = ChainRecursive.@chain begin
    keyword
    Dict
    Arguments(positional, _)
    Call(_, f)
end

import Base.==

==(a::Arguments, b::Arguments) =
    (a.positional == b.positional) && (a.keyword == b.keyword)

==(a::Call, b::Call) =
    (a.function_call == b.function_call) && (a.arguments == b.arguments)

Base.run(a::Arguments, f::Function) = f(a.positional...; a.keyword...)
Base.run(l::Call) = run(l.arguments, l.function_call)

show_pair(p) = string(p[1], " = ", p[2])
paste_two(a, b) = string(a, ", ", b)

Base.string(a::Arguments) = begin
    positional_string = reduce(paste_two, [a.positional...])
    keyword_string =
        reduce(paste_two, [string(k, " = ", v) for (k, v) in a.keyword] )
    string(positional_string, "; ", keyword_string)
end

Base.string(l::Call) = string(l.function_call, "(", l.arguments, ")")

Base.show(io::IO, a::Arguments) = show(io, string(a))
Base.show(io::IO, l::Call) = show(io, string(l))
