var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#LazyCall.collect_call-Tuple",
    "page": "Home",
    "title": "LazyCall.collect_call",
    "category": "Method",
    "text": "collect_call(positional...; keyword...)\n\nCollect a Call.\n\n\n\n"
},

{
    "location": "index.html#LazyCall.lazy_call_methods-Tuple",
    "page": "Home",
    "title": "LazyCall.lazy_call_methods",
    "category": "Method",
    "text": "@lazy_call_methods fs...\n\nFor each function in fs, create a method that takes aWW Call. This method will make assumptions about argument order. Positional arguments from the outer call will be inserted between the first (typically a function) and second positional arguments of the inner Call. This makes sense in many cases. For more complicated cases, like mapreducedim, Call methods can be defined by hand. Robost lazy systems would likely need to make use of a much more complicated type hierarchy than can be automatically generated.\n\njulia> using LazyCall, ChainRecursive\n\njulia> run_it_once(f, e) = f(e);\n\njulia> run_it_twice(f, e) = run_it_once(f, run_it_once(f, e) );\n\njulia> run_it_thrice(f, e) = run_it_twice(f, run_it_once(f, e) );\n\njulia> @lazy_call_methods run_it_once run_it_twice run_it_thrice;\n\njulia> initial_number = 0;\n\njulia> run_it_thrice( @unweave ~initial_number + 1)\n3\n\n\n\n"
},

{
    "location": "index.html#LazyCall.lazy_call_module_methods-Tuple{Any,Vararg{Any,N} where N}",
    "page": "Home",
    "title": "LazyCall.lazy_call_module_methods",
    "category": "Method",
    "text": "@lazy_call_methods a_module fs...\n\nSame as lazy_call_methods fs functions that are in a_module.\n\njulia> using LazyCall, ChainRecursive\n\njulia> @lazy_call_module_methods Base Generator mapreduce\n\njulia> version_1 = @chain begin\n           [-2, 0, -2, 0]\n           @unweave ~it + 1 > 0\n           Base.Generator(it)\n           sum(it)\n        end\n2\n\njulia> version_2 = @chain begin\n           [-2, 0, -2, 0]\n           @unweave ~it + 1 > 0\n           mapreduce(it, +)\n       end\n2\n\njulia> version_1 == version_2\ntrue\n\n\n\n"
},

{
    "location": "index.html#LazyCall.unweave-Tuple{Any}",
    "page": "Home",
    "title": "LazyCall.unweave",
    "category": "Method",
    "text": "@unweave e\n\nInterprets e as a function with its arguments wrapped in ~. Will return a Call, with an anonymous function as the first positional argument.\n\nBoth variables and expressions can be woven in.\n\njulia> using LazyCall, ChainRecursive\n\njulia> list_of_numbers = [1, 2];\n\njulia> lazy = @unweave vcat( ~list_of_numbers, ~[3, 4], 1);\n\njulia> broadcast(lazy) == broadcast(list_of_numbers, [3, 4] ) do A, B\n           vcat(A, B, 1)\n       end\ntrue\n\nVariables need only be marked once as arguments.\n\njulia> using LazyCall, ChainRecursive\n\njulia> list_of_numbers = [1, 2];\n\njulia> lazy = @unweave vcat( ~list_of_numbers, list_of_numbers);\n\njulia> broadcast(lazy) == map(list_of_numbers) do number\n           vcat(number, number)\n       end\ntrue\n\nNo more than one splatted positional argument can be woven in.\n\njulia> using LazyCall, ChainRecursive\n\njulia> first_nested_list = [1, 2], [3, 4];\n\njulia> second_nested_list = [5, 6], [7, 8];\n\njulia> lazy = @unweave vcat( ~(first_nested_list...) );\n\njulia> broadcast(lazy) == broadcast(vcat, first_nested_list ...)\ntrue\n\njulia> @unweave vcat( ~(first_nested_list...), ~(second_nested_list...) )\nERROR: syntax: invalid ... on non-final argument\n[...]\n\nNo more than one splatted keyword argument can be woven in.\n\njulia> using LazyCall, ChainRecursive\n\njulia> keyword_arguments(; kwargs...) = kwargs;\n\njulia> first_keywords = keyword_arguments( a = 1, b = 2);\n\njulia> second_keywords = keyword_arguments( c = 3, d = 4);\n\njulia> lazy = @unweave keyword_arguments(; ~(first_keywords...) );\n\njulia> run(lazy) == keyword_arguments(; first_keywords...)\ntrue\n\njulia> @unweave keyword_arguments(; ~( first_keywords...), ~( second_keywords ...) )\nERROR: Can only weave in one (set of) parameters\n[...]\n\n\n\n"
},

{
    "location": "index.html#LazyCall.@lazy_call_methods",
    "page": "Home",
    "title": "LazyCall.@lazy_call_methods",
    "category": "Macro",
    "text": "See documentation of lazy_call_methods\n\n\n\n"
},

{
    "location": "index.html#LazyCall.@lazy_call_module_methods",
    "page": "Home",
    "title": "LazyCall.@lazy_call_module_methods",
    "category": "Macro",
    "text": "See documentation of lazy_call_module_methods\n\n\n\n"
},

{
    "location": "index.html#LazyCall.@unweave",
    "page": "Home",
    "title": "LazyCall.@unweave",
    "category": "Macro",
    "text": "See documentation of unweave\n\n\n\n"
},

{
    "location": "index.html#LazyCall.Call",
    "page": "Home",
    "title": "LazyCall.Call",
    "category": "Type",
    "text": "immutable Call\n\nWill store positional and keyword arguments. Create with collect_call or unweave.\n\nYou can include positional arguments, keyword arguments, or both.\n\njulia> using LazyCall\n\njulia> collect_call(1, 2)\n1, 2\n\njulia> collect_call(a = 1, b = 2)\n; a = 1, b = 2\n\njulia> collect_call(1, 2, a = 1, b = 2)\n1, 2; a = 1, b = 2\n\nThey are equal if all of their elements are equal and the positional arguments are in the right order. Keyword order doesn't matter.\n\njulia> using LazyCall\n\njulia> collect_call(1, 2, a = 1, b = 2) == collect_call(1, 2, b = 2, a = 1)\ntrue\n\nYou can copy them to avoid accidentally overwriting keyword arguments.\n\njulia> using LazyCall\n\njulia> test = collect_call(a = 1);\n\njulia> copy_test = copy(test);\n\njulia> copy_test.keyword[:b] = 2;\n\njulia> test.keyword == copy_test.keyword\nfalse\n\nYou can merge two Calls, optionally at a specific position.\n\njulia> using LazyCall, ChainRecursive\n\njulia> base = collect_call(1, 2, a = 3, b = 4);\n\njulia> addition = collect_call(5, a = 6, c = 7);\n\njulia> merge(base, addition) == collect_call(1, 2, 5; a = 6, b = 4, c = 7)\ntrue\n\njulia> merge(base, addition, 2) == collect_call(1, 5, 2; a = 6, b = 4, c = 7)\ntrue\n\njulia> merge(base, addition, 4)\nERROR: Call `a` must have at least position - 1 positional arguments\n[...]\n\nYou can push, unshift, or insert in new arguments.\n\njulia> using LazyCall, ChainRecursive\n\njulia> base = collect_call(1, 2, a = 3, b = 4);\n\njulia> push(base, 5, a = 6, c = 7) ==\n           collect_call(1, 2, 5; a = 6, b = 4, c = 7)\ntrue\n\njulia> unshift(base, 5, a = 6, c = 7) ==\n           collect_call(5, 1, 2; a = 6, b = 4, c = 7)\ntrue\n\njulia> insert(base, 2, 5, a = 6, c = 7) ==\n           collect_call(1, 5, 2; a = 6, b = 4, c = 7)\ntrue\n\nYou can run a function on a call.\n\njulia> using LazyCall, ChainRecursive\n\njulia> @chain begin\n           collect_call(1, 2)\n           run(it, vcat)\n       end\n2-element Array{Int64,1}:\n 1\n 2\n\nIf you run a Call by itself, it calls the first positional argument on the rest of the positional and keyword arguments.\n\njulia> using LazyCall\n\njulia> collect_call(vcat, 1, 2) |> run\n2-element Array{Int64,1}:\n 1\n 2\n\n\n\n"
},

{
    "location": "index.html#LazyCall.jl-1",
    "page": "Home",
    "title": "LazyCall.jl",
    "category": "section",
    "text": "LazyCall allows you to store a function along with its arguments for later use. This is particularly useful in functional programming.Methods on LazyCalls are currently defined for one Base function: broadcast. Use lazy_call_methods to easily define more.Modules = [LazyCall]"
},

]}
