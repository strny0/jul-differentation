include("Parser.jl")
include("AST.jl")

# Example usage
expr = "cos(sin(x*pi/4)/sin(x*pi))"
func_ast = parse_function(expr)

open("test.dot", "w") do f
    write(f, ast_to_dot(expr, func_ast))
end
