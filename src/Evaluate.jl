function evaluate(node::ASTNode)::Float64
    evaluate(node, "", 0.0)
end

function evaluate(node::ASTNode, variable::String, value::Float64)::Float64
    if node isa NumberNode
        return node.value
    elseif node isa VariableNode
        if node.name == variable
            return value
        else
            error("Unable to evaluate multivariable expression at this time.") # TODO: Expand
        end
    elseif node isa ConstantNode
        return node.value
    elseif node isa UnaryOpNode
        if node.op == '-'
            return -1.0 * evaluate(node.child)
        else
            error("Unsupported unary operation '$(node.op)'.")
        end
    elseif node isa BinaryOpNode
        if node.op == '+'
            return evaluate(node.left, variable, value) + evaluate(node.right, variable, value)
        elseif node.op == '-'
            return evaluate(node.left, variable, value) - evaluate(node.right, variable, value)
        elseif node.op == '*'
            return evaluate(node.left, variable, value) * evaluate(node.right, variable, value)
        elseif node.op == '/'
            return evaluate(node.left, variable, value) / evaluate(node.right, variable, value)
        elseif node.op == '^'
            return evaluate(node.left, variable, value)^evaluate(node.right, variable, value)
        else
            error("Unsupported binary operation '$(node.op)'.")
        end
    elseif node isa FunctionNode
        if node.func == "sin"
            return sin(evaluate(node.arg, variable, value))
        elseif node.func == "cos"
            return cos(evaluate(node.arg, variable, value))
        elseif node.func == "ln"
            return log(evaluate(node.arg, variable, value))
        else
            error("Unsupported function '$(node.func)'.")
        end
    else
        error("Simplificaiton not implemented for this type of node")
    end
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
