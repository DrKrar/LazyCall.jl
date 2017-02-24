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
    "text": "immutable Call\n\nWill store positional and keyword arguments. Create with collect_call or unweave.\n\nYou can include positional arguments, keyword arguments, or both.\n\njulia> using LazyCall\n\njulia> collect_call(1, 2)\n1, 2\n\njulia> collect_call(a = 1, b = 2)\n; a = 1, b = 2\n\njulia> collect_call(1, 2, a = 1, b = 2)\n1, 2; a = 1, b = 2\n\nThey are equal if all of their elements are equal and the positional arguments are in the right order. Keyword order doesn't matter.\n\njulia> using LazyCall\n\njulia> collect_call(1, 2, a = 1, b = 2) == collect_call(1, 2, b = 2, a = 1)\ntrue\n\nYou can merge two Calls.\n\njulia> using LazyCall, ChainRecursive\n\njulia> @chain begin\n           merge(\n               collect_call(1, a = 2, b = 3),\n               collect_call(4, a = 5, c = 6)\n            )\n            _ == collect_call(1, 4; a = 5, b = 3, c = 6)\n       end\ntrue\n\nYou can push in new arguments.\n\njulia> using LazyCall, ChainRecursive\n\njulia> @chain begin\n           collect_call(1, a = 2, b = 3)\n           push(_, 4, a = 5, c = 6)\n           _ == collect_call(1, 4; a = 5, b = 3, c = 6)\n       end\ntrue\n\nYou can unshift in new arguments.\n\njulia> using LazyCall, ChainRecursive\n\njulia> @chain begin\n           collect_call(1, a = 2, b = 3)\n           unshift(_, 4, a = 5, c = 6)\n           _ == collect_call(4, 1; a = 2, b = 3, c = 6)\n       end\ntrue\n\nWhen you run a Call, it calls the first positional argument on the rest of the positional and keyword arguments.\n\njulia> using LazyCall\n\njulia> collect_call(vcat, 1, 2) |> run\n2-element Array{Int64,1}:\n 1\n 2\n\n\n\n"
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
    "location": "index.html#LazyCall.lazy_call_methods-Tuple{Any,Vararg{Any,N} where N}",
    "page": "Home",
    "title": "LazyCall.lazy_call_methods",
    "category": "Method",
    "text": "@lazy_call_methods a_module fs...\n\nFor each function in fs in a_module, create a method that takes a Call. This method will make assumptions about argument order. Positional arguments from the outer call will be inserted between the first (typically a function) and second positional arguments of the inner [Call]. This makes sense in many cases. For more complicated cases, like mapreducedim, Call methods can be defined by hand.\n\njulia> using LazyCall, ChainRecursive\n\njulia> @lazy_call_methods Base Generator mapreduce\n\njulia> version_1 = @chain begin\n           [-2, 0, -2, 0]\n           @unweave ~_ + 1 > 0\n           Base.Generator(_)\n           sum(_)\n        end\n2\n\njulia> version_2 = @chain begin\n           [-2, 0, -2, 0]\n           @unweave ~_ + 1 > 0\n           mapreduce(_, +)\n       end\n2\n\njulia> version_1 == version_2\ntrue\n\n\n\n"
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
    "location": "index.html#LazyCall.@lazy_call_methods",
    "page": "Home",
    "title": "LazyCall.@lazy_call_methods",
    "category": "Macro",
    "text": "See documentation of lazy_call_methods\n\n\n\n"
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
    "text": "@unweave e\n\nInterprets e as a function with its arguments wrapped in tildas and woven into it. Will return a Call, with an anonymous function as the first positional argument.\n\nBoth variables and expressions can be woven in.\n\njulia> using LazyCall, ChainRecursive\n\njulia> A = [1, 2];\n\njulia> @chain begin\n           @unweave vcat(~A, ~[3, 4] )\n           broadcast(_)\n           _ == broadcast(vcat, A, [3, 4] )\n       end\ntrue\n\nVariables need only be marked once as arguments.\n\njulia> using LazyCall, ChainRecursive\n\njulia> A = [1, 2];\n\njulia> @chain begin\n           @unweave vcat(~A, A)\n           broadcast(_)\n           _ == map(vcat, A, A)\n       end\ntrue\n\nNo more than one splatted positional argument can be woven in.\n\njulia> using LazyCall, ChainRecursive\n\njulia> A = [1, 2], [3, 4];\n\njulia> B = [5, 6], [7, 8];\n\njulia> @chain begin\n           @unweave vcat( ~(A...) )\n           broadcast(_)\n           _ == broadcast(vcat, A...)\n       end\ntrue\n\njulia> @unweave vcat( ~(A...), ~(B...) )\nERROR: syntax: invalid ... on non-final argument\n[...]\n\nNo more than one splatted keyword argument can be woven in.\n\njulia> using LazyCall, ChainRecursive\n\njulia> keyword_arguments(; kwargs...) = kwargs;\n\njulia> A = keyword_arguments( a = 1, b = 2);\n\njulia> B = keyword_arguments( c = 3, d = 4);\n\njulia> @chain begin\n           @unweave keyword_arguments(; ~(A...) )\n           run(_)\n           _ == keyword_arguments(; A...)\n       end\ntrue\n\njulia> @unweave keyword_arguments(; ~( A...), ~(B...) )\nERROR: Can only weave in one (set of) parameters\n[...]\n\nWith no woven arguments, Call will only contain a dummy anonymous function.\n\njulia> using LazyCall\n\njulia> run(@unweave 1)\n1\n\n\n\n"
},

{
    "location": "index.html#LazyCall.jl-1",
    "page": "Home",
    "title": "LazyCall.jl",
    "category": "section",
    "text": "LazyCall allows you to store a function along with its arguments for later use. This is particularly useful in functional programming.Methods on LazyCalls are currently defined for one Base function: broadcast. Use lazy_call_methods to easily define more.Modules = [LazyCall]"
},

]}
