var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#LazyCall.Call",
    "page": "Home",
    "title": "LazyCall.Call",
    "category": "Type",
    "text": "immutable Call\n\nWill store positional and keyword arguments. Create with collect_call or unweave.\n\nYou can include positional arguments, keyword arguments, or both.\n\njulia> using LazyCall\n\njulia> collect_call(1, 2)\n1, 2\n\njulia> collect_call(a = 1, b = 2)\n; a = 1, b = 2\n\njulia> collect_call(1, 2, a = 1, b = 2)\n1, 2; a = 1, b = 2\n\nThey are equal if all of their elements are equal and the positional arguments are in the right order. Keyword order doesn't matter.\n\njulia> using LazyCall\n\njulia> collect_call(1, 2, a = 1, b = 2) == collect_call(1, 2, b = 2, a = 1)\ntrue\n\nYou can merge two Calls.\n\njulia> using LazyCall\n\njulia> merge(\n           collect_call(1, a = 2, b = 3),\n           collect_call(4, a = 5, c = 6)\n       )\n1, 4; c = 6, a = 5, b = 3\n\nYou can push in new arguments.\n\njulia> using LazyCall\n\njulia> initial = collect_call(1, a = 2, b = 3);\n\njulia> push(initial, 4, a = 5, c = 6)\n1, 4; c = 6, a = 5, b = 3\n\nYou can unshift in new arguments.\n\njulia> using LazyCall\n\njulia> initial = collect_call(1, a = 2, b = 3);\n\njulia> unshift(initial, 4, a = 5, c = 6)\n4, 1; c = 6, a = 2, b = 3\n\nWhen you run a Call, it calls the first positional argument on the rest of the positional and keyword arguments.\n\njulia> using LazyCall\n\njulia> run( collect_call(vcat, 1, 2) )\n2-element Array{Int64,1}:\n 1\n 2\n\nSeveral new methods for base functions are defined on Calls. See documentation for a full list.\n\njulia> using LazyCall\n\njulia> map( @unweave vcat(~[1, 2], ~[3, 4]) ) == map(vcat, [1, 2], [3, 4] )\ntrue\n\n\n\n"
},

{
    "location": "index.html#LazyCall.bit_not",
    "page": "Home",
    "title": "LazyCall.bit_not",
    "category": "Function",
    "text": "bit_not\n\nAlias for ~ for use within @unweave.\n\nexamples\n\njulia> using LazyCall\n\njulia> bit_not(1) == ~1\ntrue\n\n\n\n"
},

{
    "location": "index.html#LazyCall.collect_call-Tuple",
    "page": "Home",
    "title": "LazyCall.collect_call",
    "category": "Method",
    "text": "collect_call(positional...; keyword...)\n\nCollect a Call.\n\njulia> using LazyCall\n\njulia> collect_call(1, 2, a = 1, b = 2)\n1, 2; a = 1, b = 2\n\n\n\n"
},

{
    "location": "index.html#LazyCall.push-Tuple{LazyCall.Call,Vararg{Any,N} where N}",
    "page": "Home",
    "title": "LazyCall.push",
    "category": "Method",
    "text": "push\n\nSame as push! but will leave arguments unchanged.\n\n\n\n"
},

{
    "location": "index.html#LazyCall.unshift-Tuple{LazyCall.Call,Vararg{Any,N} where N}",
    "page": "Home",
    "title": "LazyCall.unshift",
    "category": "Method",
    "text": "unshift\n\nSame as unshift! but will leave arguments unchanged.\n\n\n\n"
},

{
    "location": "index.html#LazyCall.@unweave",
    "page": "Home",
    "title": "LazyCall.@unweave",
    "category": "Macro",
    "text": "See documentation of unweave\n\n\n\n"
},

{
    "location": "index.html#LazyCall.unweave-Tuple{Any}",
    "page": "Home",
    "title": "LazyCall.unweave",
    "category": "Method",
    "text": "@unweave e\n\nInterprets e as a function with its arguments wrapped in tildas and woven into it. Will return a Call, with an anonymous function as the first positional argument.\n\nBoth variables and expressions can be woven in.\n\njulia> using LazyCall\n\njulia> A = [1, 2];\n\njulia> map( @unweave vcat(~A, ~[3, 4] ) ) == map(vcat, A, [3, 4])\ntrue\n\nVariables need only be marked once as arguments.\n\njulia> using LazyCall\n\njulia> A = [1, 2];\n\njulia> map( @unweave vcat(~A, A) ) == map( @unweave vcat(~A, ~A) )\ntrue\n\nNo more than one splatted positional argument can be woven in.\n\njulia> using LazyCall\n\njulia> A = [1, 2], [3, 4];\n\njulia> B = [5, 6], [7, 8];\n\njulia> map( @unweave vcat( ~(A...) ) ) == map(vcat, A...)\ntrue\n\njulia> @unweave vcat( ~(A...), ~(B...) )\nERROR: syntax: invalid ... on non-final argument\n[...]\n\nNo more than one splatted keyword argument can be woven in.\n\njulia> using LazyCall\n\njulia> keyword_arguments(; kwargs...) = kwargs;\n\njulia> A = keyword_arguments( a = 1, b = 2);\n\njulia> B = keyword_arguments( c = 3, d = 4);\n\njulia> run( @unweave keyword_arguments(; ~(A...) ) ) ==\n           keyword_arguments(; A...)\ntrue\n\njulia> @unweave keyword_arguments(; ~( A...), ~(B...) )\nERROR: Can only weave in one (set of) parameters\n[...]\n\nWith no woven arguments, Call will only contains an dummy anonymous function.\n\njulia> using LazyCall\n\njulia> run( @unweave 1)\n1\n\n\n\n"
},

{
    "location": "index.html#LazyCall.jl-1",
    "page": "Home",
    "title": "LazyCall.jl",
    "category": "section",
    "text": "Documentation for LazyCall.jlModules = [LazyCall]"
},

]}
