abstract type ASTNode end

struct ConstantNode <: ASTNode
    name::String
    value::Float64
end

# Supported constants
constant_map = Dict(
    "π" => 3.141592653589793,
    "pi" => 3.141592653589793,
    "e" => 2.718281828459045,
)

struct FunctionNode <: ASTNode
    func::String
    arg::ASTNode
end

# Supported functions
supported_functions = ["sin", "cos", "tan", "log", "ln"]

struct BinaryOpNode <: ASTNode
    op::Char
    left::ASTNode
    right::ASTNode
end

struct NumberNode <: ASTNode
    value::Float64
end

struct VariableNode <: ASTNode
    name::String
end
