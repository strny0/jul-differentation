module AST
export (pretty_print_ast,
ast_to_dot,
ConstantNode,
constant_map,
FunctionNode,
supported_functions,
BinaryOpNode,
NumberNode,
VariableNode,
ASTNode
)

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

function pretty_print_ast(node::ASTNode, indent::Int=0)
    indent_str = "  "^indent

    if node isa NumberNode
        println(indent_str, "NumberNode: ", node.value)

    elseif node isa VariableNode
        println(indent_str, "VariableNode: ", node.name)

    elseif node isa ConstantNode
        println(indent_str, "ConstantNode: ", node.name, " (", node.value, ")")

    elseif node isa BinaryOpNode
        println(indent_str, "BinaryOpNode: ", node.op)
        pretty_print_ast(node.left, indent + 1)
        pretty_print_ast(node.right, indent + 1)

    elseif node isa FunctionNode
        println(indent_str, "FunctionNode: ", node.func)
        pretty_print_ast(node.arg, indent + 1)

    else
        println(indent_str, "Unknown Node Type")
    end
end

global node_counter = 1
function get_unique_node_label()
    label = "node" * string(node_counter)
    global node_counter += 1
    return label
end

function ast_to_dot(expr::String, node::ASTNode)
    dot_str = "digraph AST {\n"
    dot_str *= "label=\"$expr\"\n"
    dot_str *= _ast_to_dot_helper(node, nothing)
    dot_str *= "}\n"
    return dot_str
end

function _ast_to_dot_helper(node::ASTNode, parent_label::Union{Nothing,String})
    current_label = get_unique_node_label()
    dot_str = ""

    if node isa NumberNode
        println("$current_label [label=\"$(node.value)\"];\n")
        dot_str *= "$current_label [label=\"$(node.value)\"];\n"
    elseif node isa VariableNode
        println("$current_label [label=\"$(node.name)\"];\n")
        dot_str *= "$current_label [label=\"$(node.name)\"];\n"
    elseif node isa ConstantNode
        dot_str *= "$current_label [label=\"$(node.name)\"];\n"
    elseif node isa BinaryOpNode
        dot_str *= "$current_label [label=\"$(node.op)\"];\n"
        dot_str *= _ast_to_dot_helper(node.left, current_label)
        dot_str *= _ast_to_dot_helper(node.right, current_label)
    elseif node isa FunctionNode
        dot_str *= "$current_label [label=\"$(node.func)\"];\n"
        dot_str *= _ast_to_dot_helper(node.arg, current_label)
    else
        dot_str *= "$current_label [label=\"Unknown\"];\n"
    end

    if parent_label !== nothing
        dot_str *= "$parent_label -> $current_label;\n"
    end

    dot_str
end

end