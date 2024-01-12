abstract type ASTNode end

abstract type TermNode <: ASTNode end

struct NumberNode <: TermNode
    value::Float64
end
Base.show(io::IO, m::NumberNode) = print(io, m.value)

struct VariableNode <: TermNode
    name::String
end
Base.show(io::IO, m::VariableNode) = print(io, m.name)

struct ConstantNode <: TermNode
    name::String
    value::Float64
end
Base.show(io::IO, m::ConstantNode) = print(io, m.name)

struct FunctionNode <: ASTNode
    func::String
    arg::ASTNode
end
Base.show(io::IO, m::FunctionNode) = print(io, m.func, '(', m.arg, ')')

struct UnaryOpNode <: ASTNode
    op::Char
    child::ASTNode
end
Base.show(io::IO, m::UnaryOpNode) = print(io, m.op, m.child)

struct BinaryOpNode <: ASTNode
    op::Char
    left::ASTNode
    right::ASTNode
end
Base.show(io::IO, m::BinaryOpNode) = print(io, "($(m.left))$(m.op)($(m.right))")

"""
    pretty_print_ast(node::ASTNode, indent::Int=0)

Pretty-prints the given AST node and its children recursively with indentation.

# Arguments
- `node::ASTNode`: The AST node to be printed.
- `indent::Int=0`: The initial indentation level (default is 0).
"""
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
"""
    get_unique_node_label() -> String

Generates a unique label for AST nodes used in graph visualization. This label is used in the dot representation of the AST and will not be visible.

# Returns
- `String`: A unique label for an AST node.
"""
function get_unique_node_label()
    label = "node" * string(node_counter)
    global node_counter += 1
    return label
end

"""
    ast_to_dot(expr::String, node::ASTNode) -> String

Converts the AST represented by `node` into a DOT graph description, using labels from `expr`.

# Arguments
- `expr::String`: The original expression string for labeling the graph.
- `node::ASTNode`: The root node of the AST to be converted.

# Returns
- `String`: A DOT language representation of the AST.
"""
function ast_to_dot(expr::String, node::ASTNode)
    dot_str = "digraph AST {\n"
    dot_str *= "label=\"$expr\"\n"
    dot_str *= "layout=dot\n"
    dot_str *= _ast_to_dot_helper(node, nothing)
    dot_str *= "}\n"
    return dot_str
end

"""
    _ast_to_dot_helper(node::ASTNode, parent_label::Union{Nothing,String}) -> String

Helper function for `ast_to_dot`, recursively converting AST nodes to DOT graph descriptions.

# Arguments
- `node::ASTNode`: The current node being processed.
- `parent_label::Union{Nothing,String}`: The label of the parent node in the DOT graph.

# Returns
- `String`: The partial DOT language representation of the AST from this node downwards.
"""
function _ast_to_dot_helper(node::ASTNode, parent_label::Union{Nothing,String})
    current_label = get_unique_node_label()
    dot_str = ""

    if node isa NumberNode
        dot_str *= "$current_label [label=\"$(node.value)\"];\n"
    elseif node isa VariableNode
        dot_str *= "$current_label [label=\"$(node.name)\"];\n"
    elseif node isa ConstantNode
        dot_str *= "$current_label [label=\"$(node.name)\"];\n"
    elseif node isa UnaryOpNode
        dot_str *= "$current_label [label=\"$(node.op)\"];\n"
        dot_str *= _ast_to_dot_helper(node.child, current_label)
    elseif node isa BinaryOpNode
        dot_str *= "$current_label [label=\"$(node.op)\"];\n"
        dot_str *= _ast_to_dot_helper(node.left, current_label)
        dot_str *= _ast_to_dot_helper(node.right, current_label)
    elseif node isa FunctionNode
        dot_str *= "$current_label [label=\"$(node.func)\"];\n"
        dot_str *= _ast_to_dot_helper(node.arg, current_label)
    else
        dot_str *= "$current_label [label=\"Not implemented node\"];\n"
    end

    if parent_label !== nothing
        dot_str *= "$parent_label -> $current_label;\n"
    end

    dot_str
end
