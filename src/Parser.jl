is_token_type(token, token_type) = token isa token_type

function parse_tokens(tokens::TokenVector)::ASTNode
    stack = DS.Deque{ASTNode}()
    op_stack = DS.Deque{Token}()
    for token in tokens
        parse_token!(token, stack, op_stack)
    end

    while !isempty(op_stack)
        apply_operator!(stack, pop!(op_stack))
    end

    return isempty(stack) ? error("Invalid expression") : last(stack)
end

function parse_token!(token::NumberToken, stack, op_stack)
    push!(stack, NumberNode(token.value))
end

function parse_token!(token::VariableToken, stack, op_stack)
    push!(stack, VariableNode(token.name))
end

function parse_token!(token::ConstantToken, stack, op_stack)
    push!(stack, ConstantNode(token.name, get(constant_map, token.name, 0.0)))
end

function parse_token!(token::OperatorToken, stack, op_stack)
    while !isempty(op_stack) && _precedence(last(op_stack)) >= _precedence(token)
        apply_operator!(stack, pop!(op_stack))
    end
    push!(op_stack, token)
end

function parse_token!(token::LeftParenToken, stack, op_stack)
    push!(op_stack, token)
end

function parse_token!(token::RightParenToken, stack, op_stack)
    while !isempty(op_stack) && !is_token_type(last(op_stack), LeftParenToken)
        apply_operator!(stack, pop!(op_stack))
    end
    pop!(op_stack)
end

function parse_token!(token::FunctionToken, stack, op_stack)
    push!(op_stack, token)
end

function apply_operator!(stack, token)
    if is_token_type(token, OperatorToken)
        op = token.op
        if op in ['+', '-', '*', '/']
            rhs = pop!(stack)
            lhs = pop!(stack)
            push!(stack, BinaryOpNode(op, lhs, rhs))
        elseif op == '^'
            exponent = pop!(stack)
            base = pop!(stack)
            push!(stack, BinaryOpNode('^', base, exponent))
        end
    elseif is_token_type(token, FunctionToken)
        arg = pop!(stack)
        push!(stack, FunctionNode(token.func, arg))
    else
        error("Not implemented token application rule.")
    end
end

function _precedence(token::LeftParenToken)
    return 0
end

function _precedence(token::OperatorToken)
    pmap = Dict(
        '+' => 1,
        '-' => 1,
        '*' => 2,
        '/' => 2,
        '^' => 3,
    )
    return get(pmap, token.op) do
        error("Unimplemented operator.")
    end
end

function _precedence(token::FunctionToken)
    return 4
end

parse_function(expr::String) = parse_tokens(tokenize(expr))
