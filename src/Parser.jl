module Parser
export parse_function

include("Tokens.jl")
include("AST.jl")

is_token_type(token, token_type) = token isa token_type

function parser(tokens::Vector{Token})
    current_token_index = Ref(1)
    return parse_expr_precedence1(tokens, current_token_index)
end

function parse_expr_precedence1(tokens::Vector{Token}, current_token_index::Base.RefValue{Int})
    lhs = parse_expr_precedence2(tokens, current_token_index)
    while current_token_index[] <= length(tokens) && is_token_type(tokens[current_token_index[]], OperatorToken) && (tokens[current_token_index[]].op in ['+', '-'])
        op = tokens[current_token_index[]].op
        current_token_index[] += 1
        rhs = parse_expr_precedence2(tokens, current_token_index)
        lhs = BinaryOpNode(op, lhs, rhs)
    end
    return lhs
end

function parse_expr_precedence2(tokens::Vector{Token}, current_token_index::Base.RefValue{Int})
    lhs = parse_expr_precedence3(tokens, current_token_index)
    while current_token_index[] <= length(tokens) && is_token_type(tokens[current_token_index[]], OperatorToken) && (tokens[current_token_index[]].op in ['*', '/'])
        op = tokens[current_token_index[]].op
        current_token_index[] += 1
        rhs = parse_expr_precedence3(tokens, current_token_index)
        lhs = BinaryOpNode(op, lhs, rhs)
    end
    return lhs
end

function parse_expr_precedence3(tokens::Vector{Token}, current_token_index::Base.RefValue{Int})
    if current_token_index[] > length(tokens)
        error("Unexpected end of expression")
    end

    base = parse_base(tokens, current_token_index)

    if current_token_index[] <= length(tokens) && is_token_type(tokens[current_token_index[]], OperatorToken) && tokens[current_token_index[]].op == '^'
        current_token_index[] += 1
        exponent = parse_expr_precedence3(tokens, current_token_index)  # Exponent itself can be a complex factor
        return BinaryOpNode('^', base, exponent)
    else
        return base
    end
end

function parse_base(tokens::Vector{Token}, current_token_index::Base.RefValue{Int})
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
    elseif is_token_type(token, OperatorToken) && (token.op == 'p' || token.op == 'm') # Handle unary operators
        operand = parse_expr_precedence3(tokens, current_token_index)
        if token.op == 'm'
            return BinaryOpNode('-', NumberNode(-1), operand)
        else
            return operand
        end
    elseif is_token_type(token, LeftParenToken)
        expr = parse_expr_precedence1(tokens, current_token_index)
        if current_token_index[] > length(tokens) || !is_token_type(tokens[current_token_index[]], RightParenToken)
            error("Expected ')'")
        end
        current_token_index[] += 1
        return expr
    elseif is_token_type(token, FunctionToken)
        if current_token_index[] > length(tokens) || !is_token_type(tokens[current_token_index[]], LeftParenToken)
            error("Expected '(' after function token")
        end
        current_token_index[] += 1

        arg = parse_expr_precedence1(tokens, current_token_index)

        if current_token_index[] > length(tokens) || !is_token_type(tokens[current_token_index[]], RightParenToken)
            error("Expected ')' after function argument")
        end
        current_token_index[] += 1

        return FunctionNode(token.func, arg)
    else
        error("Unexpected token: $token")
    end
end

parse_function(expr::String) = parser(tokenize(expr))

end