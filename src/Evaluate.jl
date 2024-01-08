include("AST.jl")


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
        # ["sin", "cos", "tan", "log", "ln"]
        if node.func == "sin"
            return sin(evaluate(node.arg, variable, value))
        elseif node.func == "cos"
            return cos(evaluate(node.arg, variable, value))
        elseif node.func == "tan"
            return tan(evaluate(node.arg, variable, value))
        elseif node.func == "log"
            return log(evaluate(node.arg, variable, value))
        elseif node.func == "ln"
            return log(evaluate(node.arg, variable, value))
        else
            error("Unsupported function '$(node.func)'.")
        end
    else
        error("Simplificaiton not implemented for this type of node")
    end
end
