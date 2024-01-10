include("AST.jl")
include("Parser.jl")
include("Simplifier.jl")

function differentiate(node::ASTNode, wrt_var::String)
    if node isa NumberNode
        return NumberNode(0.0)
    elseif node isa VariableNode
        return NumberNode(node.name == wrt_var ? 1.0 : 0.0)
    elseif node isa ConstantNode
        return NumberNode(0.0)
    elseif node isa UnaryOpNode
        return UnaryOpNode('-', differentiate(node.child, wrt_var))
    elseif node isa BinaryOpNode
        return differentiate_binary_op(node, wrt_var)
    elseif node isa FunctionNode
        return differentiate_function(node, wrt_var)
    else
        error("Differentiation not implemented for this type of node")
    end
end

function differentiate_binary_op(node::BinaryOpNode, wrt_var::String)
    if node.op == '+' # Differentiate parts
        return BinaryOpNode('+', differentiate(node.left, wrt_var), differentiate(node.right, wrt_var))
    elseif node.op == '*' # Product rule
        left_diff = BinaryOpNode('*', node.left, differentiate(node.right, wrt_var))
        right_diff = BinaryOpNode('*', differentiate(node.left, wrt_var), node.right)
        return BinaryOpNode('+', left_diff, right_diff)
    elseif node.op == '/' # Quotient rule
        numerator = BinaryOpNode('+', BinaryOpNode('*', node.right, differentiate(node.left, wrt_var)), UnaryOpNode('-', BinaryOpNode('*', node.left, differentiate(node.right, wrt_var))))
        denominator = BinaryOpNode('^', node.right, NumberNode(2.0))
        return BinaryOpNode('/', numerator, denominator)
    elseif node.op == '^'
        if node.right isa NumberNode # Simple case of power rule
            exponent = node.right.value
            new_exponent = NumberNode(exponent - 1)
            u_to_the_new_exponent = BinaryOpNode('^', node.left, new_exponent)
            du_dx = differentiate(node.left, wrt_var)
            return BinaryOpNode('*', BinaryOpNode('*', NumberNode(exponent), u_to_the_new_exponent), du_dx)
        else # Chain rule
            u = node.left
            v = node.right
            u_prime = differentiate(u, wrt_var)
            v_prime = differentiate(v, wrt_var)
            first_term = BinaryOpNode('*', v_prime, FunctionNode("ln", u))
            second_term = BinaryOpNode('*', v, BinaryOpNode('/', u_prime, u))
            derivative = BinaryOpNode('+', first_term, second_term)
            return BinaryOpNode('*', BinaryOpNode('^', u, v), derivative)
        end
    else
        error("Differentiation not implemented for this operator")
    end
end

function differentiate_function(node::FunctionNode, variable::String)
    if node.func == "sin"
        return BinaryOpNode('*', differentiate(node.arg, variable), FunctionNode("cos", node.arg))
    elseif node.func == "cos"
        return BinaryOpNode('*', differentiate(node.arg, variable), BinaryOpNode('*', NumberNode(-1.0), FunctionNode("sin", node.arg)))
    elseif node.func == "ln"
        return BinaryOpNode('*', differentiate(node.arg, variable), BinaryOpNode('/', NumberNode(1.0), node.arg))
    else
        error("Unsupported function '$(node.func)'.")
    end
end

expr = "sin(x)/cos(x)"
func = simplify(parse_function(expr))
diff = simplify(differentiate(func, "x"))

format_function(func)
diff_str = format_function(diff)

open("test.dot", "w") do f
    write(f, ast_to_dot("∂f/∂x $expr =\n$diff_str", diff))
end
