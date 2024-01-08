include("AST.jl")
include("Evaluate.jl")

function subtree_contains_variable(node::ASTNode)::Bool
    if node isa NumberNode
        return false
    elseif node isa VariableNode
        return true
    elseif node isa ConstantNode
        return false
    elseif node isa BinaryOpNode
        return subtree_contains_variable(node.left) || subtree_contains_variable(node.right)
    elseif node isa FunctionNode
        return subtree_contains_variable(node.arg)
    else
        error("Not implemented for this type of node")
    end
end

function simplify(node::ASTNode)::ASTNode
    if node isa NumberNode
        return node
    elseif node isa VariableNode
        return node
    elseif node isa ConstantNode
        return node
    elseif node isa BinaryOpNode
        left = !subtree_contains_variable(node.left) ? NumberNode(evaluate(node.left)) : simplify(node.left)
        right = !subtree_contains_variable(node.right) ? NumberNode(evaluate(node.right)) : simplify(node.right)

        if node.op == '*'
            if (left == right)
                return BinaryOpNode('^', left, NumberNode(2.0))
            end

            if (left isa NumberNode)
                if (left.value == 0.0)
                    return NumberNode(0.0)
                elseif (left.value == 1.0)
                    return right
                end
            end

            if (right isa NumberNode)
                if (right.value == 0.0)
                    return NumberNode(0.0)
                elseif (right.value == 1.0)
                    return left
                end
            end
        elseif node.op == "/"
            if (left == right) # assuming right is not 0
                return NumberNode(1.0)
            end
        end

        return BinaryOpNode(node.op, left, right)
    elseif node isa FunctionNode
        return FunctionNode(node.func, simplify(node.arg))
    else
        error("Simplificaiton not implemented for this type of node")
    end
end
