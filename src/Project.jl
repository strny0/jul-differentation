module Project

include("Maps.jl")
include("Tokens.jl")
include("AST.jl")
include("Parser.jl")
include("Differentiation.jl")
include("Simplifier.jl")
include("Evaluate.jl")

export parse_function,
    differentiate,
    ast_to_dot,
    evaluate,
    format_function,
    simplify

end
