module SymbollicDerivation

import DataStructures as DS

include("Maps.jl")
include("Tokens.jl")
include("AST.jl")
include("Parser.jl")
include("Differentiation.jl")
include("Simplifier.jl")
include("Evaluate.jl")

export parse_function,
    parse_tokens,
    differentiate,
    ast_to_dot,
    evaluate,
    format_function,
    simplify,
    tokenize
end
