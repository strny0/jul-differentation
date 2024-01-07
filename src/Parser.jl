include("Tokens.jl")
include("AST.jl")

function tokenize(expr::String)
    tokens = Token[]
    i = 1
    while i <= length(expr)
        c = expr[i]
        if c in "0123456789."
            start = i
            while i <= length(expr) && (expr[i] in "0123456789." || (i > start && expr[i] == 'e'))
                i += 1
            end
            push!(tokens, NumberToken(parse(Float64, expr[start:i-1])))
        elseif c in "+-*/^"
            push!(tokens, OperatorToken(c))
            i += 1
        elseif c == '('
            push!(tokens, LeftParenToken())
            i += 1
        elseif c == ')'
            push!(tokens, RightParenToken())
            i += 1
        elseif isletter(c) || c == '_'
            start = i
            while i <= length(expr) && (isletter(expr[i]) || isdigit(expr[i]) || expr[i] == '_')
                i += 1
            end
            token_str = expr[start:i-1]
            if token_str in supported_functions
                push!(tokens, FunctionToken(token_str))
            elseif token_str in keys(constant_map)
                push!(tokens, ConstantToken(token_str))
            else
                push!(tokens, VariableToken(token_str))
            end
        else
            i += 1
        end
    end
    return tokens
end

is_token_type(token, token_type) = token isa token_type

function parser(tokens::Vector{Token})
    current_token_index = Ref(1)
    return parse_expression(tokens, current_token_index)
end

function parse_expression(tokens::Vector{Token}, current_token_index::Base.RefValue{Int})
    expr = parse_term(tokens, current_token_index)
    while current_token_index[] <= length(tokens) && is_token_type(tokens[current_token_index[]], OperatorToken) && (tokens[current_token_index[]].op in ['+', '-'])
        op = tokens[current_token_index[]].op
        current_token_index[] += 1
        rhs = parse_term(tokens, current_token_index)
        expr = BinaryOpNode(op, expr, rhs)
    end
    return expr
end

function parse_term(tokens::Vector{Token}, current_token_index::Base.RefValue{Int})
    term = parse_factor(tokens, current_token_index)
    while current_token_index[] <= length(tokens) && is_token_type(tokens[current_token_index[]], OperatorToken) && (tokens[current_token_index[]].op in ['*', '/'])
        op = tokens[current_token_index[]].op
        current_token_index[] += 1
        rhs = parse_factor(tokens, current_token_index)
        term = BinaryOpNode(op, term, rhs)
    end
    return term
end

function parse_factor(tokens::Vector{Token}, current_token_index::Base.RefValue{Int})
    if current_token_index[] > length(tokens)
        error("Unexpected end of expression")
    end

    token = tokens[current_token_index[]]
    current_token_index[] += 1

    if is_token_type(token, NumberToken)
        return NumberNode(token.value)
    elseif is_token_type(token, VariableToken)
        return VariableNode(token.name)
    elseif is_token_type(token, ConstantToken)
        return ConstantNode(token.name, get(constant_map, token.name, 0))
    elseif is_token_type(token, LeftParenToken)
        expr = parse_expression(tokens, current_token_index)
        if current_token_index[] > length(tokens) || !is_token_type(tokens[current_token_index[]], RightParenToken)
            error("Expected ')'")
        end
        current_token_index[] += 1
        return expr
    elseif is_token_type(token, FunctionToken)
        arg = parse_factor(tokens, current_token_index)
        return FunctionNode(token.func, arg)
    else
        error("Unexpected token: $token")
    end
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

# Example usage
expr = "sin(x*pi/4) + 3 * 2/6 + 7"
tokens = tokenize(expr)
ast = parser(tokens)

open("test.dot", "w") do f
    write(f, ast_to_dot(expr, ast))
end
