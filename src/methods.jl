user_method(f) = :( $f(l::$Call) = $f(l.positional...; l.keyword...) )
base_method(f) = user_method( :($Base.$f) )
map_block(f, es) = Expr(:block, map(f, es)...)
base_methods(fs...) = map_block(base_method, fs)

macro base_methods(es...)
    esc(base_methods(es...))
end

@base_methods map filter broadcast Generator
