import DataStructures as DS

function subtree_contains_variable(node::ASTNode)::Bool
    stack = DS.Stack{ASTNode}()
    push!(stack, node)

    while !isempty(stack)
        current = pop!(stack)

        if current isa NumberNode || current isa ConstantNode
            continue
        elseif current isa VariableNode
            return true
        elseif current isa UnaryOpNode
            push!(stack, current.child)
        elseif current isa BinaryOpNode
            push!(stack, current.left)
            push!(stack, current.right)
        elseif current isa FunctionNode
            push!(stack, current.arg)
        else
            error("Not implemented for this type of node")
        end
    end
    return false
end

function simplify(node::ASTNode)::ASTNode
    prev = nothing
    while node != prev
        prev = deepcopy(node)
        node = simplify_helper(node)
    end
    return node
end

function simplify_helper(root_node::ASTNode)::ASTNode
    simplified_nodes = Dict{ASTNode,ASTNode}()
    stack = DS.Stack{Tuple{ASTNode,Bool}}()
    push!(stack, (root_node, false))

    while !isempty(stack)
        (node, is_processed) = pop!(stack)

        if is_processed
            simplified_nodes[node] = simplify_node(node, simplified_nodes)
            continue
        end

        push!(stack, (node, true))
        if node isa UnaryOpNode
            push!(stack, (node.child, false))
        elseif node isa BinaryOpNode
            push!(stack, (node.left, false))
            push!(stack, (node.right, false))
        elseif node isa FunctionNode
            push!(stack, (node.arg, false))
        end
    end

    return get(simplified_nodes, root_node, root_node)
end

function simplify_node(node::ASTNode, simplified_nodes::Dict{ASTNode,ASTNode})::ASTNode
    if node isa TermNode
        return node
    elseif node isa UnaryOpNode
        child = get(simplified_nodes, node.child, node.child)
        if node.op == '-' && child isa UnaryOpNode && child.op == '-'
            return child.child
        elseif node.op == '-' && child isa BinaryOpNode && child.op == '*'
            if child.left isa UnaryOpNode && child.left.op == '-'
                return BinaryOpNode('*', child.left.child, child.right)
            elseif child.right isa UnaryOpNode && child.right.op == '-'
                return BinaryOpNode('*', child.left, child.right.child)
            end
        else
            return UnaryOpNode('-', child)
        end
    elseif node isa BinaryOpNode
        left = get(simplified_nodes, node.left, node.left)
        right = get(simplified_nodes, node.right, node.right)
        if node.op == '+'
            if (!(left isa TermNode) && right isa TermNode)
                t = left
                left = right
                right = t
            end

            if (left == right)
                return BinaryOpNode('*', left, NumberNode(2.0))
            end

            if (left isa NumberNode && left.value == 0.0)
                return right
            elseif (right isa NumberNode && right.value == 0.0)
                return left
            end
        elseif node.op == '*'
            if (!(left isa TermNode) && right isa TermNode)
                t = left
                left = right
                right = t
            end

            if (left isa NumberNode)
                if (left.value == 0.0)
                    return NumberNode(0.0)
                elseif (left.value == 1.0)
                    return right
                elseif (left.value == -1.0)
                    return UnaryOpNode('-', right)
                end
            elseif (right isa NumberNode)
                if (right.value == 0.0)
                    return NumberNode(0.0)
                elseif (right.value == 1.0)
                    return left
                elseif (right.value == -1.0)
                    return UnaryOpNode('-', left)
                end
            end

            if (right isa BinaryOpNode && right.op == '*' && left == right.left)
                return BinaryOpNode('*', BinaryOpNode('^', left, NumberNode(2.0)), right.right)
            end

            if (left == right)
                return BinaryOpNode('^', left, NumberNode(2.0))
            end

        elseif node.op == "/"
            if (left == NumberNode(0.0))
                return NumberNode(0.0)
            elseif (left == right) # assuming right is not 0, otherwise it is a bug
                return NumberNode(1.0)
            end
        elseif node.op == '^'
            if (node.right == NumberNode(1.0))
                return node.left
            end
        end

        return BinaryOpNode(node.op, left, right)
    elseif node isa FunctionNode
        arg = get(simplified_nodes, node.arg, node.arg)
        if (node.func in ["ln"] && node.arg == ConstantNode("e", get(constant_map, "e", -)))
            return NumberNode(1.0)
        end
        return FunctionNode(node.func, arg)
    else
        error("Simplificaiton not implemented for this type of node.")
    end

    return node
end
