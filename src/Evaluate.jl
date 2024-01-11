function evaluate(node::ASTNode)::Float64
    evaluate(node, "", 0.0)
end

function evaluate(node::NumberNode, variable::String, value::Float64)::Float64
    return node.value
end

function evaluate(node::ConstantNode, variable::String, value::Float64)::Float64
    return node.value
end

function evaluate(node::VariableNode, variable::String, value::Float64)::Float64
    return node.name == variable ? value : error("Unable to evaluate multivariable expression.")
end

function evaluate(node::UnaryOpNode, variable::String, value::Float64)::Float64
    if node.op == '-'
        return -1.0 * evaluate(node.child, variable, value)
    else
        error("Unsupported unary operation '$(node.op)'.")
    end
end

function evaluate(node::BinaryOpNode, variable::String, value::Float64)::Float64
    op = get(operator_map, node.op) do
        error("Unsupported binary operation '$(node.op)'.")
    end
    return op(evaluate(node.left, variable, value), evaluate(node.right, variable, value))
end

function evaluate(node::FunctionNode, variable::String, value::Float64)::Float64
    func = get(function_map, node.func) do
        error("Unsupported function '$(node.func)'.")
    end
    return func(evaluate(node.arg, variable, value))
end

function evaluate(node::ASTNode, variable::String, value::Float64)::Float64
    error("Simplificaiton not implemented for this type of node")
end

function format_function(node::ASTNode; top=true)::String
    out = ""
    paren = false
    if node isa NumberNode
        out = "$(node.value)"
    elseif node isa VariableNode
        out = node.name
    elseif node isa ConstantNode
        out = node.name
    elseif node isa UnaryOpNode
        if node.op == '-'
            out = "(-" * format_function(node.child; top=false) * ")"
        else
            error("Unsupported unary operation '$(node.op)'.")
        end
    elseif node isa BinaryOpNode
        paren = true
        if node.op == '+'
            out = format_function(node.left; top=false) * " + " * format_function(node.right; top=false)
        elseif node.op == '*'
            out = format_function(node.left; top=false) * " * " * format_function(node.right; top=false)
        elseif node.op == '/'
            out = format_function(node.left; top=false) * "/" * format_function(node.right; top=false)
        elseif node.op == '^'
            out = format_function(node.left; top=false) * "^" * format_function(node.right; top=false)
        else
            error("Unsupported binary operation '$(node.op)'.")
        end
    elseif node isa FunctionNode
        out = "$(node.func)(" * format_function(node.arg; top=false) * ")"
    else
        error("Formatting not implemented for this type of node")
    end
    if paren && !top && !(startswith(out, '(') && endswith(out, ')'))
        out = "(" * out * ")"
    end
    return out
end
