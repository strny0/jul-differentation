include("AST.jl")

function subtree_contains_variable(node::ASTNode)
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

function simplify(node::ASTNode)
    if node isa NumberNode
        return node
    elseif node isa VariableNode
        return node
    elseif node isa ConstantNode
        return node
    elseif node isa BinaryOpNode
        left = !subtree_contains_variable(node.left) ? evaluate(node.left) : simplify(node.left)
        right = !subtree_contains_variable(node.left) ? evaluate(node.left) : simplify(node.left)
        return BinaryOpNode(node.op, left, right)
    elseif node isa FunctionNode
        return FunctionNode(node.func, simplify(node.arg))
    else
        error("Simplificaiton not implemented for this type of node")
    end
end
